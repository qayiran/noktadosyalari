#!/usr/bin/env fish

sleep 5

while true
    echo "Fetching new art... 🎨"
    nice -n 19 ionice -c 3 python /home/qayiran/ilo/pinterest_scraper.py

    # Strictly kill ONLY the python widget and launch the new one
    pkill -f "true_widget.py"
    nice -n 19 ionice -c 3 python /home/qayiran/ilo/true_widget.py & disown

    echo "Done! Aesthetic perfectly painted on the background layer. 💖"
    sleep 3600
end
