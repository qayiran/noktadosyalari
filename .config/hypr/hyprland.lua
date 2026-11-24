-- https://wiki.hypr.land/Configuring/Start/


--------------------
---- MONİTÖRLËR ----
--------------------

-- Bak https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output    = "",
    mode      = "highres",
    position  = "auto",
    scale     = "1.6",
    transform = 0,
})


----------------------
---- PROGRAMLARIM ----
----------------------

local terminal    = "foot"
local fileManager = "foot -e yazi"
local menu        = "rofi -show run"


------------------
---- BAŞLATMA ----
------------------

-- Bak https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function ()
    -- Sistëm ve Masa Üstü
    hl.exec_cmd("plymouth --quit")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY HYPRLAND_INSTANCE_SIGNATURE")

    hl.exec_cmd("systemctl --user start dunst")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    hl.exec_cmd("xdg-user-dirs-update")

    hl.exec_cmd("steam -silent")
    hl.exec_cmd("xrdb -merge ~/.Xresources")
    hl.exec_cmd("vesktop --start-minimized")
    -- hl.exec_cmd("~/ilo/sleep_monitor.fish &")

    -- Temalandırma
    hl.exec_cmd("hyprctl setcursor Posy_Cursor 32")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Posy_Cursor'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 32")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface accent-color 'red'")

    -- Hayaalet Programlar ve Barlar
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd('awww img "$HOME/sitelen sinpin/taskimaidenv2.jpg"')
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --watch $HOME/ilo/pano store")

    -- Ses
    hl.exec_cmd("easyeffects --gapplication-service")

    -- Kullanıcı Betikleri
    -- hl.exec_cmd("python $HOME/ilo/gcp_widget.py &")
    hl.exec_cmd("$HOME/ilo/pin_loop.fish")
end)


----------------------------
---- ÇEVRE DEĞİŞKËNLERİ ----
----------------------------

-- Bak https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("XCURSOR_THEME", "Posy_Cursor")
hl.env("XCURSOR_SIZE", "32")
hl.env("HYPRCURSOR_THEME", "Posy_Cursor")
hl.env("HYPRCURSOR_SIZE", "32")

hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_USE_PORTAL", "1")
hl.env("QT_QPA_PLATFORMTHEME", "xdgdesktopportal")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Hibrit GPU (iGPU masaüstü + dGPU oyun/YZ)
hl.env("LIBVA_DRIVER_NAME", "iHD")

hl.env("XKB_CONFIG_HOME", "$HOME/.config/xkb")


------------------------
---- GÖRÜNÜM VE HİS ----
------------------------

-- Başvur https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = "10",
        border_size = 2,

        -- Renklër
        col = {
            active_border   = "rgba(d23d50ff)",
            inactive_border = "rgba(7a756faa)",
        },

        -- Boyutlandırma
        resize_on_border = false,
        layout           = "dwindle",

        -- Yırtılma
        allow_tearing = true,
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Opaklık
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        -- Bulanıklık (Blur)
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
            xray     = true,
        },
    },

    animations = {
        enabled = true,
    },

    -- Daha fazlası için bak https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
    dwindle = {
        preserve_split = true,
    },

    -- Daha fazlası için https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    master = {
        new_status = "master",
    },

    xwayland = {
        force_zero_scaling = true,
    },

    misc = {
        force_default_wallpaper    = -1,
        disable_hyprland_logo      = true,
        initial_workspace_tracking = 0,
        focus_on_activate          = true,
        vrr                        = 2,
    },

    render = {
        direct_scanout = 2,
    },

    cursor = {
        no_hardware_cursors = true,
    },
})

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},  {0.32, 1}   } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},     {1, 1}      } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1}   } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},  {0.1, 1}    } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


---------------
---- GİRDİ ----
---------------

hl.config({
    input = {
        kb_layout          = "tr_custom",
        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0,      -- -1.0 - 1.0, 0 düzënleme yok demek.
        accel_profile      = "flat", -- Bu faare ivmelenimini kapatır.

        touchpad = {
            natural_scroll = false,
        },

        tablet = {
            enabled = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


-----------------------
---- TUŞ ATAMALARI ----
-----------------------

local mainMod = "SUPER" -- "Windows" tuşunu ana düzënleyici olarak belirlër.

-- Daha fazlası için https://wiki.hypr.land/Configuring/Basics/Binds/

-- Uygulama Başlatıcılar
hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("foot --app-id=foot-float"))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("$HOME/ilo/pano menu"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("$HOME/ilo/pano images"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("$HOME/ilo/toggle_fans.sh"))

-- Pencere Yönetimi
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", function()
    local win = hl.get_active_window()
    if not win then return end
    if not win.floating then
        hl.dispatch(hl.dsp.window.float({ action = "enable" }))
        hl.dispatch(hl.dsp.window.resize({ x = 1280, y = 720 }))
        hl.dispatch(hl.dsp.window.center())
    else
        hl.dispatch(hl.dsp.window.float({ action = "disable" }))
    end
end)
hl.bind(mainMod .. " + P",   hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",   hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L",   hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + M",   hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + F11", hl.dsp.window.fullscreen())

-- Odak
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Çalışma Alanları
for i = 1, 10 do
    local key = i % 10 -- 10 0 tuşuna eşlër
    hl.bind("ALT + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind("ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + SHIFT + N", hl.dsp.window.move({ workspace = "empty" }))

-- Özël Çalışma Alanları
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Çalışma Alanlarını Kaydırma
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Faare ile Pencere Kontrolü
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Medya & Donanım Tuşları
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("$HOME/ilo/osd.fish mic-mute"),                    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("$HOME/ilo/osd.fish bri-up"),                      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("$HOME/ilo/osd.fish bri-down"),                    { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Resim & Video Kaydı
hl.bind("Print",                   hl.dsp.exec_cmd("sh -c 'grim -g \"$(slurp)\" - | tee \"$HOME/sitelen/$(date +%Y-%m-%d_%H-%M-%S).png\" | wl-copy -t image/png'"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("$HOME/ilo/record-toggle"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("$HOME/ilo/save_pin.fish"))


----------------------------------------
---- PENCERELËR VE ÇALIŞMA ALANLARI ----
----------------------------------------

-- Bak https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- ve https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Genël Pencere Kuralları

-- Maksimize etme isteklerini yok say
hl.window_rule({
    name           = "ignore-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- XWayland sürüklenimini düzëlt
hl.window_rule({
    name     = "fix-xwayland-drag",
    match    = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Spesifik Uygulama Kuralları

-- Oyunlar
hl.window_rule({
    name      = "games-tearing-allow",
    match     = { class = "^(steam_app_.*|gamescope|osu\\!)$" },
    immediate = true,
})

-- Sims ve Photoshop
hl.window_rule({
    name    = "apps-float-center",
    match   = { class = "^(Sims\\.exe|steam_app_3042768914)$" },
    float   = true,
    center  = true,
    monitor = 0,
})

-- Pinterest Zımbırtısı
hl.window_rule({
    name        = "pinterest-widget-float",
    match       = { class = "^(pin_widget)$" },
    float       = true,
    workspace   = "1",
    size        = "300 450",
    move        = "monitor_w-330 30",
    no_focus    = true,
    no_shadow   = true,
    no_blur     = true,
    border_size = 0,
})

-- Ses Karıştırıcısı (Pavucontrol / Pulsemixer)
hl.window_rule({
    name    = "audio-mixer-float",
    match   = { class = "^(org\\.pulseaudio\\.pavucontrol|pulsemixer)$" },
    float   = true,
    size    = "1050 620",
    center  = true,
    opacity = "0.92 0.88",
})

-- Resim Görüntüleyicilër (Swayimg / Imv / Nsxiv)
hl.window_rule({
    name        = "image-viewer-float",
    match       = { class = "^(swayimg|imv|[Nn]sxiv)$" },
    float       = true,
    size        = "1280 800",
    center      = true,
    no_shadow   = true,
    no_blur     = true,
    border_size = 0,
})

-- Telegram Arama ve Ortam Pencereleri
hl.window_rule({
    name   = "telegram-call-float",
    match  = {
        class         = "^(org\\.telegram\\.desktop)$",
        initial_title = "negative:^(Telegram|Media viewer|Ortam görüntüleyici)$",
    },
    float  = true,
    size   = "420 620",
    center = true,
})

hl.window_rule({
    name   = "telegram-media-float",
    match  = {
        class         = "^(org\\.telegram\\.desktop)$",
        initial_title = "^(Media viewer|Ortam görüntüleyici)$",
    },
    float  = true,
    size   = "1280 800",
    center = true,
})

-- Steam, Discord, Vesktop ve ZapZap Ek Pencereleri
hl.window_rule({
    name   = "steam-popups-float",
    match  = {
        class         = "^(steam)$",
        initial_title = "negative:^(Steam)$",
    },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "discord-popups-float",
    match  = {
        class         = "^(vesktop|discord)$",
        initial_title = "negative:^((\\([0-9]+\\) )?(Discord|Vesktop)( [|-].*)?|.* [-|] Discord)$",
    },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "zapzap-popups-float",
    match  = {
        class         = "^(zapzap|com\\.rtosta\\.zapzap)$",
        initial_title = "negative:^(ZapZap)$",
    },
    float  = true,
    center = true,
})

-- Resim İçinde Resim (PiP), Apple Music ve Video Oynatıcı (mpv)
hl.window_rule({
    name              = "pip-float",
    match             = { title = "^(Picture-in-Picture|Resim içinde resim)$" },
    float             = true,
    pin               = true,
    keep_aspect_ratio = true,
    size              = "480 270",
    move              = "monitor_w-500 50",
})

hl.window_rule({
    name   = "apple-music-float",
    match  = { class = "^(crx_blgdilankhbcpipclgpdndahbehalgkh)$" },
    float  = true,
    size   = "1100 720",
    center = true,
})

hl.window_rule({
    name              = "mpv-float",
    match             = { class = "^(mpv)$" },
    float             = true,
    keep_aspect_ratio = true,
    size              = "1280 720",
    center            = true,
})

-- Portallar, Modallar, Yetkilendirme ve Wine İletişim Kutuları
hl.window_rule({
    name   = "portals-float",
    match  = { class = "^(xdg-desktop-portal-gtk|org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde)$" },
    float  = true,
    size   = "1050 680",
    center = true,
})

hl.window_rule({
    name   = "modal-dialogs-float",
    match  = { modal = true },
    float  = true,
    center = true,
})

hl.window_rule({
    name       = "polkit-float",
    match      = { class = "^(hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1)$" },
    float      = true,
    center     = true,
    dim_around = true,
})

hl.window_rule({
    name   = "wine-dialogs-float",
    match  = { class = "^(org\\.gnome\\.Zenity|zenity|winetricks|steam_app_0)$" },
    float  = true,
    center = true,
})

-- Yardımcı Araçlar ve Yüzer Uçbirim
hl.window_rule({
    name   = "network-editor-float",
    match  = { class = "^(nm-connection-editor)$" },
    float  = true,
    size   = "680 560",
    center = true,
})

hl.window_rule({
    name   = "recorder-gui-float",
    match  = { class = "^(com\\.dec05eba\\.gpu_screen_recorder|gpu-screen-recorder-gtk)$" },
    float  = true,
    size   = "900 620",
    center = true,
})

hl.window_rule({
    name   = "utils-float",
    match  = { class = "^(com\\.github\\.wwmm\\.easyeffects|easyeffects|org\\.rncbc\\.qpwgraph|qpwgraph|nwg-look|gay\\.pancake\\.lsfg-vk-ui)$" },
    float  = true,
    size   = "1100 720",
    center = true,
})

hl.window_rule({
    name   = "foot-float",
    match  = { class = "^(foot-float)$" },
    float  = true,
    size   = "850 520",
    center = true,
})

-- Katman Kuralları (Layer Rules)
hl.layer_rule({
    name  = "notifications-blur",
    match = { namespace = "notifications" },
    blur  = true,
})

hl.layer_rule({
    name  = "rofi-blur",
    match = { namespace = "rofi" },
    blur  = true,
})
