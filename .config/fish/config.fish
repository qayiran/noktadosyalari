if status is-interactive
    # This makes sure NVM uses a version of Node automatically
    set -g nvm_default_version lts
end

if status is-login
    if test (tty) = /dev/tty1; and test (whoami) = "qayiran"
        # We try to run Hyprland. If it exits with an error...
        if not start-hyprland
            echo "---------------------------------------"
            echo "Hyprland failed to start, you klutz! 💢"
            echo "Check your config or logs with 'journalctl -xe'"
            echo "---------------------------------------"
        else
            # If it exits normally, we log out to keep things clean.
            exit
        end
    end
end

if status is-interactive
    abbr -a mnt-iphone 'mkdir -p ~/wan/Yipkin; ifuse ~/wan/Yipkin'
    abbr -a umnt-iphone 'fusermount -u ~/wan/Yipkin'
end

function fish_greeting
    /home/qayiran/ilo/ay/.venv/bin/python /home/qayiran/ilo/ay/ay.py
    set_color normal
    if status is-interactive
        phoon -l 5
    end
    # 1. This is the magic! If it's 4:00 AM Tuesday, it looks back 8 hours to 8:00 PM Monday.
    set -l day (date -d "8 hours ago" "+%A")
    set -l hour (math (date "+%H"))

    # 2. Logic for Day vs Night (Staying within your 08:00 - 20:00 rule)
    set -l time_of_day "night"
    if test $hour -ge 8 -a $hour -lt 20
        set time_of_day "day"
    else
        set time_of_day "night"
    end
    
    # 3. Your switch statement
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
    
        # 2. Print your "cute" message
        set_color -o magenta
        echo "✨ $random_poke! ✨"
        set_color normal
        echo ""
        # 3. Show the actual artwork
        pokemon-colorscripts -n $random_poke --no-title
end

# Set the new GOPATH and add its bin folder to PATH
set -gx GOPATH $HOME/.local/share/go
fish_add_path $GOPATH/bin

# pyenv setup
set -x PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
pyenv init - | source

# Update Reminder Script
if status is-interactive
    set -l last_update_file ~/.config/fish/.last_update_check
    set -l current_time (date +%s)

    if test -f $last_update_file
        set last_time (cat $last_update_file)
    else
        set last_time 0
    end

    # 259200 seconds is exactly 3 days
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

alias up='paru && date +%s > ~/.config/fish/.last_update_check'

alias comfy="cd ~/qayiran/ijo/ComfyUI; source venv/bin/activate.fish; python main.py"

function waifu
    # 'nohup' prevents the app from dying if you eventually close the terminal
    # '>/dev/null 2>&1' hides all the annoying GTK warnings from your screen
    nohup waifudownloader >/dev/null 2>&1 &
    # 'disown' cuts the tie so the shell doesn't track it as a "job"
    disown
end

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

function moon
    curl "wttr.in/Moon@Ayvalık?F"
end

alias JDownloader2="nohup ~/.local/share/jd2/JDownloader2 >/dev/null 2>&1 & disown"

set -gx EDITOR micro

function pony
    set -lx PYTHONWARNINGS ignore
    # Redirect stderr to /dev/null to kill that 'Bad file descriptor' message
    command ponysay $argv 2>/dev/null | cat
end

function sitelen
    # Save current location
    set prev_dir $PWD
    
    cd ~/qayiran/sitelen
    
    # setsid -f forces it to fork to the background automatically.
    # We also completely removed the pipe and used command substitution
    # because pipes make process detachment messy!
    setsid -f nsxiv -t -- (ls -t) >/dev/null 2>&1
    
    # Jump back
    cd $prev_dir
end

function zap
    env QT_QPA_PLATFORM=xcb zapzap > /dev/null 2>&1 & disown
end

alias tetris='retroarch -L /usr/lib/libretro/nestopia_libretro.so "qayiran/ijo/SOB/Tetris (USA).nes" &> /dev/null & disown'

alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

function sor
    echo "Mistral-Nemo yükleniyor..."
    
    # 1. Start the AI in the background
    cd ~/qayiran/ijo/YZ/text-generation-webui
    nohup ./start_linux.sh --api --model Mistral-Nemo-Instruct-2407-Q5_K_M.gguf > /dev/null 2>&1 &
    cd -
    
    echo "API'ın uyanması bekleniyor..."
    
    # 2. Loop until the API actually responds to a ping so aichat doesn't crash
    while not curl -s http://127.0.0.1:5000/v1/models > /dev/null
        sleep 2
    end
    
    echo "Anık."
    
    # 3. Open aichat. Passing $argv means you can still ask one-liners if you want!
    aichat --role tsundere $argv
    
    # 4. Once you type /exit or hit Ctrl+D in aichat, this cleanup part runs automatically!
    echo "Dil modeli kapatılıyor."
    pkill -f "start_linux.sh"
    pkill -f "server.py --api"
    
    echo "VRAM temizlëndi."
end

alias imageranker="cd ~/ilo/image-ranker; source .venv/bin/activate.fish; image-ranker"

# Force a success exit code so Qayiran doesn't panic!
true

