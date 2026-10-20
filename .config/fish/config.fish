# -----------------------------------------
# ---- ÇEVRE DEĞİŞKËNLERİ VE YOL (PATH) ----
# -----------------------------------------

set -gx EDITOR micro

# Go
set -gx GOPATH $HOME/.local/share/go
fish_add_path $GOPATH/bin

# Pyenv
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
pyenv init - --no-rehash | source

# Ek Yollar
fish_add_path $HOME/.grok/bin
fish_add_path $HOME/.local/bin

if status is-interactive
    set -g nvm_default_version lts
    zoxide init fish | source
    fzf --fish | source
end


# -----------------------------------------
# ---- OTURUM BAŞLATMA (TTY1 -> HYPRLAND) ----
# -----------------------------------------

if status is-login
    if test (tty) = /dev/tty1; and test (whoami) = "qayiran"
        if not start-hyprland
            echo "---------------------------------------"
            echo "Hyprland failed to start, you klutz! 💢"
            echo "Check your config or logs with 'journalctl -xe'"
            echo "---------------------------------------"
        else
            exit
        end
    end
end


# ------------------------------------------------
# ---- KARŞILAMA VE GÜNCËLLEME HATIRLATICISI ----
# ------------------------------------------------

function fish_greeting
    /home/qayiran/ilo/ay/.venv/bin/python /home/qayiran/ilo/ay/ay.py
    set_color normal

    if status is-interactive
        phoon -l 5
    end

    # Saat 08:00 öncesi bir önceki günün gecesi sayılır
    set -l day (date -d "8 hours ago" "+%A")
    set -l hour (math (date "+%H"))

    set -l time_of_day "night"
    if test $hour -ge 8 -a $hour -lt 20
        set time_of_day "day"
    end

    switch $day
        case Pazartesi
            if test "$time_of_day" = "night"
                echo "Bu dün od dünündeyiz. İyi dünlër."
            else
                echo "Bu gün ay günündeyiz. İyi günlër."
            end
        case Salı
            if test "$time_of_day" = "night"
                echo "Bu dün su dünündeyiz. İyi dünlër."
            else
                echo "Bu gün od günündeyiz. İyi günlër."
            end
        case Çarşamba
            if test "$time_of_day" = "night"
                echo "Bu dün ağaç dünündeyiz. İyi dünlër."
            else
                echo "Bu gün su günündeyiz. İyi günlër."
            end
        case Perşembe
            if test "$time_of_day" = "night"
                echo "Bu dün altın dünündeyiz. İyi dünlër."
            else
                echo "Bu gün ağaç günündeyiz. İyi günlër."
            end
        case Cuma
            if test "$time_of_day" = "night"
                echo "Bu dün toprak dünündeyiz. İyi dünlër."
            else
                echo "Bu gün altın günündeyiz. İyi günlër."
            end
        case Cumartesi
            if test "$time_of_day" = "night"
                echo "Bu dün gün dünündeyiz. İyi dünlër."
            else
                echo "Bu gün toprak günündeyiz. İyi günlër."
            end
        case Pazar
            if test "$time_of_day" = "night"
                echo "Bu dün ay dünündeyiz. İyi dünlër."
            else
                echo "Bu gün gün günündeyiz. İyi günlër."
            end
    end

    set -l pokes (pokemon-colorscripts -l)
    set -l random_poke (string trim $pokes[(random 1 (count $pokes))])

    set_color -o magenta
    echo "✨ $random_poke! ✨"
    set_color normal
    echo ""
    pokemon-colorscripts -n $random_poke --no-title
end

# 3 Günlük Güncëlleme Hatırlatıcısı
if status is-interactive
    set -l last_update_file ~/.config/fish/.last_update_check
    set -l current_time (date +%s)

    if test -f $last_update_file
        set last_time (cat $last_update_file)
    else
        set last_time 0
    end

    set -l interval 259200
    set -l time_diff (math $current_time - $last_time)

    if test $time_diff -ge $interval
        echo -e "\n"
        set_color red --bold
        echo "Güncëlleme yapılmayalı 3 gün geçti."
        set_color yellow
        echo "Lütfën up komutunu çalıştırın."
        set_color normal
        echo -e "\n"
    end
end


# ---------------------------------------
# ---- KISALTMALAR (ABBR VE ALIAS) ----
# ---------------------------------------

if status is-interactive
    abbr -a mnt-iphone  'mkdir -p ~/wan/Yipkin; ifuse ~/wan/Yipkin'
    abbr -a umnt-iphone 'fusermount -u ~/wan/Yipkin'
end

# Sistëm ve Yönetim
alias :3="sudo"
alias up='paru && date +%s > ~/.config/fish/.last_update_check'
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias atak="hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'"
alias atgöy="hyprshutdown -t 'Restarting...' --post-cmd 'reboot'"

# Yapay Zëka (YZ)
alias comfy="cd ~/qayiran/ijo/YZ/ComfyUI; source .venv/bin/activate.fish; python main.py"
alias comfy-net="cd ~/qayiran/ijo/YZ/ComfyUI; source .venv/bin/activate.fish; python main.py --listen 0.0.0.0"
alias nemo='cd ~/qayiran/ijo/YZ/; ./start_ai.sh'

# Uygulamalar ve Oyunlar
alias imageranker="cd ~/ilo/image-ranker; source .venv/bin/activate.fish; image-ranker"
alias JDownloader2="nohup ~/.local/share/jd2/JDownloader2 >/dev/null 2>&1 & disown"
alias tetris='retroarch -L /usr/lib/libretro/nestopia_libretro.so "$HOME/qayiran/ijo/SOB/Tetris (USA).nes" &> /dev/null & disown'


# -------------------------------
# ---- İŞLËVLËR (FUNCTIONS) ----
# -------------------------------

function chill
    echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    echo "balance_power" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null
    echo "CPU rahat bırakıldı."
end

function boost
    echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    echo "balance_performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null
    echo "Turbo moduna geri dönüldü."
end

function pony
    set -lx PYTHONWARNINGS ignore
    command ponysay $argv 2>/dev/null | cat
end

function sitelen
    set -l prev_dir $PWD
    cd ~/qayiran/sitelen
    setsid -f nsxiv -t -- (ls -t) >/dev/null 2>&1
    cd $prev_dir
end

function waifu
    nohup waifudownloader >/dev/null 2>&1 &
    disown
end

function zap
    env QT_QPA_PLATFORM=xcb zapzap > /dev/null 2>&1 & disown
end

function sor
    echo "Mistral-Nemo yükleniyor..."

    cd ~/qayiran/ijo/YZ/text-generation-webui
    nohup ./start_linux.sh --api --model Mistral-Nemo-Instruct-2407-Q5_K_M.gguf > /dev/null 2>&1 &
    cd -

    echo "API'ın uyanması bekleniyor..."

    while not curl -s http://127.0.0.1:5000/v1/models > /dev/null
        sleep 2
    end

    echo "Anık."
    aichat --role tsundere $argv

    echo "Dil modeli kapatılıyor."
    pkill -f "start_linux.sh"
    pkill -f "server.py --api"

    echo "VRAM temizlëndi."
end

function dgif
    yt-dlp "$argv[1]" --exec "ffmpeg -i {} -vf 'fps=10,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse' {}.gif && rm {}"
end

function ytdvideo
    yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --merge-output-format mp4 "$argv[1]"
end

true
