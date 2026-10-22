#!/usr/bin/env fish

# ---- EKRAN KARARTMA VE HAREKËT DENETİMİ (IDLE-CTL) ----
set runtime_dir /run/user/(id -u)
set saved_file  $runtime_dir/idle_saved_brightness
set dimmed_flag $runtime_dir/idle_is_dimmed
set pid_file    $runtime_dir/idle_fade.pid

function stop_running_fade
    if test -f $pid_file
        set old_pid (cat $pid_file 2>/dev/null)
        if test -n "$old_pid"; and test "$old_pid" != "$fish_pid"
            kill $old_pid 2>/dev/null
        end
    end
end

switch $argv[1]
    case check
        # Kilit ekranındaysa her zaman karartmaya izin ver
        if pidof hyprlock >/dev/null
            exit 0
        end

        # Waybar altındaki alanı (0,30 1600x970) düşük çözünürlükte (80x48) 3 kez örnëkle
        set f1 $runtime_dir/idle_f1.ppm
        set f2 $runtime_dir/idle_f2.ppm
        set f3 $runtime_dir/idle_f3.ppm

        grim -g "0,30 1600x970" -s 0.05 -t ppm $f1 2>/dev/null; or exit 0
        sleep 0.5
        grim -g "0,30 1600x970" -s 0.05 -t ppm $f2 2>/dev/null; or exit 0
        sleep 0.5
        grim -g "0,30 1600x970" -s 0.05 -t ppm $f3 2>/dev/null; or exit 0

        set diff1 (cmp -l $f1 $f2 2>/dev/null | wc -l)
        set diff2 (cmp -l $f2 $f3 2>/dev/null | wc -l)
        rm -f $f1 $f2 $f3

        # Ekranda piksël değişimi varsa (video, yayın, oyun vb.) karartmayı engëlle
        if test $diff1 -gt 20 -o $diff2 -gt 20
            exit 1
        end
        exit 0

    case check-lock
        if pidof hyprlock >/dev/null
            exit 1
        end

        # Ekran henüz kararmadıysa (örn. video oynuyorsa) veya kararalı 5 dakika olmadıysa kilitleme
        if not test -f $dimmed_flag
            exit 1
        end

        set dim_time (stat -c %Y $dimmed_flag 2>/dev/null; or echo 0)
        set now (date +%s)
        if test (math $now - $dim_time) -lt 290
            exit 1
        end
        exit 0

    case dim
        stop_running_fade
        echo $fish_pid > $pid_file

        set cur (brightnessctl g)
        if not test -f $dimmed_flag; and test $cur -gt 10
            echo $cur > $saved_file
            touch $dimmed_flag
        end

        if test $cur -le 10
            rm -f $pid_file
            exit 0
        end

        # Yumuşak kararma geçişi (40 adım, ~0.9 saniye)
        set steps 40
        for i in (seq 1 $steps)
            set val (math --scale=0 "$cur - ($cur - 10) * $i / $steps")
            brightnessctl -q set $val
            sleep 0.015
        end
        brightnessctl -q set 10
        rm -f $pid_file

    case restore
        stop_running_fade
        echo $fish_pid > $pid_file

        set cur (brightnessctl g)
        if not test -f $dimmed_flag; and test $cur -gt 10
            rm -f $pid_file
            exit 0
        end

        set target 96000
        if test -f $saved_file
            set target (cat $saved_file)
        end
        rm -f $dimmed_flag

        if test $cur -ge $target
            brightnessctl -q set $target
            rm -f $pid_file
            exit 0
        end

        # Yumuşak aydınlanma geçişi (20 adım, ~0.3 saniye)
        set steps 20
        for i in (seq 1 $steps)
            set val (math --scale=0 "$cur + ($target - $cur) * $i / $steps")
            brightnessctl -q set $val
            sleep 0.01
        end
        brightnessctl -q set $target
        rm -f $pid_file
end
