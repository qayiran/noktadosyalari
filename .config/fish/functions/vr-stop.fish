function vr-stop --description 'Stop VR streaming and turn on screen'
    echo "Stopping Sunshine..."
    killall sunshine
    
    echo "Restoring laptop screen brightness..."
    brightnessctl set 100%
end
