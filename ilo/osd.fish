#!/usr/bin/env fish

# ---- MİKROFON VE PARLAKLIK BİLDİRİM BETİĞİ (OSD) ----

switch $argv[1]
    case mic-mute
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        set -l raw (wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
        if string match -q "*MUTED*" "$raw"
            notify-send -u low -t 1500 -h string:x-dunst-stack-tag:osd "Mikrofon" "Sessiz"
        else
            notify-send -u normal -t 1500 -h string:x-dunst-stack-tag:osd "Mikrofon" "Açık"
        end

    case bri-up
        brightnessctl -e4 -n2 set 5%+ >/dev/null
        set -l bri (brightnessctl -m | cut -d, -f4 | tr -d '%')
        notify-send -u normal -t 1500 -h string:x-dunst-stack-tag:osd -h int:value:$bri "Parlaklık" "%$bri"

    case bri-down
        brightnessctl -e4 -n2 set 5%- >/dev/null
        set -l bri (brightnessctl -m | cut -d, -f4 | tr -d '%')
        notify-send -u normal -t 1500 -h string:x-dunst-stack-tag:osd -h int:value:$bri "Parlaklık" "%$bri"
end
