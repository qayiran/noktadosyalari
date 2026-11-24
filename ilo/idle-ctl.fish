#!/usr/bin/env fish

# ---- EKRAN KARARTMA, AKTİVİTE VE İZLEME DENETİMİ (IDLE-CTL) ----
if test (count $argv) -lt 1
    exit 1
end

set -l mode $argv[1]
set -l self_path (status filename)

exec python3 -c '
import fcntl
import glob
import json
import os
import signal
import subprocess
import sys
import time

SELF_PATH = sys.argv[1]
MODE = sys.argv[2]

RUNTIME_DIR = os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
SAVED_FILE = os.path.join(RUNTIME_DIR, "idle_saved_brightness")
DIMMED_FLAG = os.path.join(RUNTIME_DIR, "idle_is_dimmed")
LAST_ACT_FILE = os.path.join(RUNTIME_DIR, "idle_last_activity")
LAST_RES_FILE = os.path.join(RUNTIME_DIR, "idle_last_resume")
INPUT_IDLE_FLAG = os.path.join(RUNTIME_DIR, "idle_input_idle")
CTL_LOCK_FILE = os.path.join(RUNTIME_DIR, "idle_ctl.lock")
FADE_PID_FILE = os.path.join(RUNTIME_DIR, "idle_fade.pid")
FADE_MODE_FILE = os.path.join(RUNTIME_DIR, "idle_fade.mode")
LOCK_DELAY_PID_FILE = os.path.join(RUNTIME_DIR, "idle_lock_delay.pid")
WATCH_PID_FILE = os.path.join(RUNTIME_DIR, "idle_watch.pid")
WATCH_LOCK_FILE = os.path.join(RUNTIME_DIR, "idle_watch.lock")

DIM_LEVEL = 10
DIM_TIMEOUT = 300.0
LOCK_TIMEOUT = 290.0
WATCH_INTERVAL = 5.0
PIXEL_DELTA_THRESHOLD = 8
CHANGED_PIXEL_MIN = 12


def atomic_write(path, content):
    tmp = f"{path}.{os.getpid()}.tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(content)
    os.replace(tmp, path)


def safe_remove(path):
    try:
        os.unlink(path)
    except FileNotFoundError:
        pass


def read_float(path, default=None):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return float(f.read().strip())
    except Exception:
        return default


def read_int(path, default=None):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return int(float(f.read().strip()))
    except Exception:
        return default


def read_str(path, default=""):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read().strip()
    except Exception:
        return default


def is_proc_running(comm_name):
    with os.scandir("/proc") as it:
        for entry in it:
            if not entry.name.isdigit():
                continue
            try:
                with open(f"/proc/{entry.name}/comm", "r", encoding="utf-8") as f:
                    if f.read().strip() == comm_name:
                        return True
            except Exception:
                continue
    return False


def find_backlight():
    preferred = "/sys/class/backlight/intel_backlight"
    if os.path.isdir(preferred):
        return "intel_backlight", preferred
    for path in sorted(glob.glob("/sys/class/backlight/*")):
        if os.path.isdir(path):
            return os.path.basename(path), path
    return None, None


BL_NAME, BL_PATH = find_backlight()


def get_brightness():
    if BL_PATH:
        val = read_int(os.path.join(BL_PATH, "brightness"))
        if val is not None:
            return val
    out = subprocess.check_output(["brightnessctl", "g"], text=True).strip()
    return int(out)


def get_max_brightness():
    if BL_PATH:
        val = read_int(os.path.join(BL_PATH, "max_brightness"))
        if val is not None and val > 0:
            return val
    try:
        out = subprocess.check_output(["brightnessctl", "m"], text=True).strip()
        val = int(out)
        if val > 0:
            return val
    except Exception:
        pass
    return 96000


_dbus_session = None


def set_brightness(val):
    global _dbus_session
    val = int(max(0, val))
    if BL_NAME:
        try:
            if _dbus_session is None:
                import dbus
                bus = dbus.SystemBus()
                _dbus_session = bus.get_object(
                    "org.freedesktop.login1",
                    "/org/freedesktop/login1/session/auto",
                )
            import dbus
            _dbus_session.SetBrightness(
                "backlight",
                BL_NAME,
                dbus.UInt32(val),
                dbus_interface="org.freedesktop.login1.Session",
            )
            return
        except Exception:
            _dbus_session = None
    subprocess.run(["brightnessctl", "-q", "set", str(val)], check=False)


def stop_pid_file(pid_file, mode_file=None, only_modes=None):
    pid = read_int(pid_file)
    if pid is None or pid == os.getpid():
        return
    if only_modes is not None and mode_file is not None:
        if read_str(mode_file) not in only_modes:
            return
    try:
        os.kill(pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    except Exception:
        pass


def open_lock(path):
    fd = os.open(path, os.O_CREAT | os.O_RDWR, 0o600)
    fcntl.flock(fd, fcntl.LOCK_EX)
    return fd


def release_lock(fd):
    try:
        fcntl.flock(fd, fcntl.LOCK_UN)
    finally:
        os.close(fd)


def touch_last_activity(now=None):
    ts = now if now is not None else time.time()
    prev = read_float(LAST_ACT_FILE, 0.0) or 0.0
    if prev > ts + 5.0:
        prev = 0.0
    if ts >= prev:
        atomic_write(LAST_ACT_FILE, f"{ts:.3f}\n")


def spawn_watcher():
    try:
        lfd = os.open(WATCH_LOCK_FILE, os.O_CREAT | os.O_RDWR, 0o600)
        try:
            fcntl.flock(lfd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            os.close(lfd)
            return
        fcntl.flock(lfd, fcntl.LOCK_UN)
        os.close(lfd)
    except Exception:
        return

    subprocess.Popen(
        [SELF_PATH, "watch"],
        start_new_session=True,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        close_fds=True,
    )


def get_capture_geometry():
    try:
        out = subprocess.check_output(
            ["hyprctl", "monitors", "-j"], text=True, timeout=1.5
        )
        monitors = json.loads(out)
        mon = next((m for m in monitors if m.get("focused")), monitors[0])
        scale = float(mon.get("scale", 1.0)) or 1.0
        mx = int(mon.get("x", 0))
        my = int(mon.get("y", 0))
        mw = int(round(float(mon["width"]) / scale))
        mh = int(round(float(mon["height"]) / scale))
        reserved = mon.get("reserved") or [0, 0, 0, 0]
        top_pad = int(reserved[1]) if len(reserved) > 1 else 0
        # Waybar altındaki alanı örnëkle
        top_off = max(top_pad + 3, 30) if top_pad > 0 else 0
        if mw > 0 and mh > top_off:
            return f"{mx},{my + top_off} {mw}x{mh - top_off}"
    except Exception:
        pass
    return "0,30 1600x970"


def grab_ppm_pixels(geom):
    cmd = ["grim"]
    if geom:
        cmd.extend(["-g", geom])
    cmd.extend(["-s", "0.05", "-t", "ppm", "-"])
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, timeout=2.0)
    if res.returncode != 0 and geom:
        res = subprocess.run(
            ["grim", "-s", "0.05", "-t", "ppm", "-"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            timeout=2.0,
        )
    if res.returncode != 0:
        return None
    data = res.stdout
    idx = data.find(b"\n255\n")
    if idx == -1:
        return None
    return data[idx + 5 :]


def count_changed_pixels(a, b):
    if len(a) != len(b):
        return CHANGED_PIXEL_MIN + 1
    changed = 0
    th = PIXEL_DELTA_THRESHOLD
    for i in range(0, len(a) - 2, 3):
        if (
            abs(a[i] - b[i]) > th
            or abs(a[i + 1] - b[i + 1]) > th
            or abs(a[i + 2] - b[i + 2]) > th
        ):
            changed += 1
            if changed > CHANGED_PIXEL_MIN:
                return changed
    return changed


def cmd_watch():
    lfd = os.open(WATCH_LOCK_FILE, os.O_CREAT | os.O_RDWR, 0o600)
    try:
        fcntl.flock(lfd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        os.close(lfd)
        return 0

    stop = False

    def handle_sig(signum, frame):
        nonlocal stop
        stop = True

    signal.signal(signal.SIGTERM, handle_sig)
    signal.signal(signal.SIGINT, handle_sig)

    atomic_write(WATCH_PID_FILE, f"{os.getpid()}\n")
    geom = get_capture_geometry()
    last_geom_ts = time.monotonic()
    prev_pixels = None
    prev_changed = False

    try:
        while not stop:
            if (
                not os.path.exists(INPUT_IDLE_FLAG)
                or os.path.exists(DIMMED_FLAG)
                or is_proc_running("hyprlock")
                or not is_proc_running("hypridle")
            ):
                break

            now_mono = time.monotonic()
            if now_mono - last_geom_ts >= 60.0:
                geom = get_capture_geometry()
                last_geom_ts = now_mono

            cur_pixels = grab_ppm_pixels(geom)
            if cur_pixels is not None:
                if prev_pixels is not None:
                    diff = count_changed_pixels(prev_pixels, cur_pixels)
                    if diff > CHANGED_PIXEL_MIN:
                        if prev_changed:
                            touch_last_activity()
                        else:
                            # Anlık bildirimleri (örn. dunst) video oynatımından ayırmak için 0.5s doğrula
                            time.sleep(0.5)
                            if stop or not os.path.exists(INPUT_IDLE_FLAG):
                                break
                            confirm_pixels = grab_ppm_pixels(geom)
                            if (
                                confirm_pixels is not None
                                and count_changed_pixels(cur_pixels, confirm_pixels) > CHANGED_PIXEL_MIN
                            ):
                                touch_last_activity()
                                prev_changed = True
                                cur_pixels = confirm_pixels
                            else:
                                prev_changed = False
                    else:
                        prev_changed = False
                prev_pixels = cur_pixels

            slept = 0.0
            while slept < WATCH_INTERVAL and not stop:
                if not os.path.exists(INPUT_IDLE_FLAG) or os.path.exists(DIMMED_FLAG):
                    stop = True
                    break
                time.sleep(0.5)
                slept += 0.5
    finally:
        safe_remove(WATCH_PID_FILE)
        release_lock(lfd)
    return 0


def cmd_mark_idle():
    if is_proc_running("hyprlock") or os.path.exists(DIMMED_FLAG):
        return 0
    now = time.time()
    atomic_write(INPUT_IDLE_FLAG, f"{now:.3f}\n")
    prev = read_float(LAST_ACT_FILE, 0.0) or 0.0
    if prev > now:
        prev = 0.0
    init_act = max(prev, now - 15.0)
    atomic_write(LAST_ACT_FILE, f"{init_act:.3f}\n")
    spawn_watcher()
    return 0


def cmd_mark_active():
    now = time.time()
    atomic_write(LAST_RES_FILE, f"{now:.3f}\n")
    touch_last_activity(now)
    safe_remove(INPUT_IDLE_FLAG)
    stop_pid_file(WATCH_PID_FILE)
    if os.path.exists(DIMMED_FLAG):
        return cmd_restore(from_active=True)
    return 0


def cmd_check():
    if is_proc_running("hyprlock"):
        return 0
    if os.path.exists(INPUT_IDLE_FLAG) and not os.path.exists(DIMMED_FLAG):
        spawn_watcher()
    now = time.time()
    last_act = read_float(LAST_ACT_FILE)
    last_res = read_float(LAST_RES_FILE)
    if last_act is None and last_res is None:
        touch_last_activity(now)
        return 1
    latest = max(last_act or 0.0, last_res or 0.0)
    if now - latest >= DIM_TIMEOUT:
        return 0
    return 1


def cmd_check_lock():
    if is_proc_running("hyprlock"):
        return 1
    if not os.path.exists(DIMMED_FLAG):
        return 1
    try:
        dim_time = os.path.getmtime(DIMMED_FLAG)
    except FileNotFoundError:
        return 1
    now = time.time()
    last_act = max(
        read_float(LAST_ACT_FILE, 0.0) or 0.0,
        read_float(LAST_RES_FILE, 0.0) or 0.0,
    )
    if (now - dim_time) >= LOCK_TIMEOUT and (now - last_act) >= LOCK_TIMEOUT:
        return 0
    return 1


def cmd_dim(mode):
    aborted = False

    def handle_sig(signum, frame):
        nonlocal aborted
        aborted = True

    signal.signal(signal.SIGTERM, handle_sig)
    signal.signal(signal.SIGINT, handle_sig)

    start_ts = time.time()
    if mode == "lock-dim":
        atomic_write(LOCK_DELAY_PID_FILE, f"{os.getpid()}\n")
        try:
            for _ in range(6):
                if aborted or (read_float(LAST_RES_FILE, 0.0) or 0.0) > start_ts:
                    return 0
                time.sleep(0.05)
        finally:
            safe_remove(LOCK_DELAY_PID_FILE)

    lfd = open_lock(CTL_LOCK_FILE)
    try:
        now = time.time()
        last_res = read_float(LAST_RES_FILE, 0.0) or 0.0
        last_act = read_float(LAST_ACT_FILE, None)
        locked = is_proc_running("hyprlock")

        if mode in ("lock-dim", "dim-lock"):
            if not locked:
                return 0
            if mode == "lock-dim":
                if last_res > start_ts:
                    return 0
            elif now - last_res < 1.0:
                return 0
        else:
            if not locked:
                if now - last_res < 5.0:
                    return 0
                if last_act is not None and (now - last_act) < (DIM_TIMEOUT - 5.0):
                    return 0

        if aborted or last_res > start_ts:
            return 0

        safe_remove(INPUT_IDLE_FLAG)
        stop_pid_file(WATCH_PID_FILE)

        cur = get_brightness()
        if not os.path.exists(DIMMED_FLAG):
            if cur <= DIM_LEVEL:
                return 0
            atomic_write(SAVED_FILE, f"{cur}\n")
            atomic_write(DIMMED_FLAG, f"{int(now)}\n")

        if cur <= DIM_LEVEL:
            return 0

        atomic_write(FADE_PID_FILE, f"{os.getpid()}\n")
        atomic_write(FADE_MODE_FILE, f"{mode}\n")

        steps = 40
        for i in range(1, steps + 1):
            if aborted or (read_float(LAST_RES_FILE, 0.0) or 0.0) > start_ts:
                return 0
            val = round(cur - (cur - DIM_LEVEL) * i / steps)
            set_brightness(val)
            time.sleep(0.015)

        if not aborted and (read_float(LAST_RES_FILE, 0.0) or 0.0) <= start_ts:
            set_brightness(DIM_LEVEL)
    finally:
        safe_remove(FADE_PID_FILE)
        safe_remove(FADE_MODE_FILE)
        release_lock(lfd)
    return 0


def cmd_restore(from_active=False, is_unlock=False):
    now = time.time()
    atomic_write(LAST_RES_FILE, f"{now:.3f}\n")
    if is_unlock:
        touch_last_activity(now)
        safe_remove(INPUT_IDLE_FLAG)
        stop_pid_file(WATCH_PID_FILE)

    # Bekleyen kilit karartmalarını ve süren karartmayı durdur; süren restore kesilmez!
    stop_pid_file(LOCK_DELAY_PID_FILE)
    stop_pid_file(FADE_PID_FILE, FADE_MODE_FILE, only_modes={"dim", "dim-lock", "lock-dim"})

    lfd = open_lock(CTL_LOCK_FILE)
    try:
        if not os.path.exists(DIMMED_FLAG):
            return 0

        cur = get_brightness()
        max_bri = get_max_brightness()
        target = read_int(SAVED_FILE, max_bri)
        if target is None or target <= DIM_LEVEL or target > max_bri:
            target = max_bri

        atomic_write(FADE_PID_FILE, f"{os.getpid()}\n")
        atomic_write(FADE_MODE_FILE, "restore\n")

        if cur < target:
            steps = 20
            for i in range(1, steps + 1):
                val = round(cur + (target - cur) * i / steps)
                set_brightness(val)
                time.sleep(0.01)

        # Hedef parlaklığa kesin ulaşana dek dimmed_flag kaldırılmaz!
        set_brightness(target)
        safe_remove(DIMMED_FLAG)
        if not from_active:
            touch_last_activity(time.time())
    finally:
        safe_remove(FADE_PID_FILE)
        safe_remove(FADE_MODE_FILE)
        release_lock(lfd)
    return 0


dispatch = {
    "watch": cmd_watch,
    "check": cmd_check,
    "check-lock": cmd_check_lock,
    "mark-idle": cmd_mark_idle,
    "mark-active": cmd_mark_active,
    "dim": lambda: cmd_dim("dim"),
    "dim-lock": lambda: cmd_dim("dim-lock"),
    "lock-dim": lambda: cmd_dim("lock-dim"),
    "restore": lambda: cmd_restore(from_active=False, is_unlock=False),
    "unlock": lambda: cmd_restore(from_active=True, is_unlock=True),
}
if MODE not in dispatch:
    sys.exit(1)
sys.exit(dispatch[MODE]())
' "$self_path" "$mode"
