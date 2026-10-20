#!/usr/bin/env fish

sleep 5

while true
    echo "Fetching new art... 🎨"
    python /home/qayiran/ilo/pinterest_scraper.py
    
    # Strictly kill ONLY the python widget and launch the new one
    pkill -f "true_widget.py"
    python /home/qayiran/ilo/true_widget.py & disown
    
    echo "Done! Aesthetic perfectly painted on the background layer. 💖"
    sleep 3600
end
