#!/usr/bin/env fish

function update_pin
    echo "Fetching new art... 🎨"
    nice -n 19 ionice -c 3 python /home/qayiran/ilo/pinterest_scraper.py

    # Strictly kill ONLY the python widget and launch the new one
    pkill -f "true_widget.py"
    nice -n 19 ionice -c 3 python /home/qayiran/ilo/true_widget.py & disown

    echo "Done! Aesthetic perfectly painted on the background layer. 💖"
end

# Kill any existing pin_loop.fish instances and their active sleep timers
for pid in (pgrep -f "pin_loop.fish")
    if test "$pid" != "$fish_pid"
        pkill -P $pid 2>/dev/null
        kill $pid 2>/dev/null
    end
end

if test "$argv[1]" = "refresh"
    update_pin
    nohup /home/qayiran/ilo/pin_loop.fish --wait >/dev/null 2>&1 & disown
    exit 0
else if test "$argv[1]" = "--wait"
    sleep 3600
else
    sleep 5
end

while true
    update_pin
    sleep 3600
end
