function vr-start --description 'Start Sunshine and turn off screen'
    echo "Starting Sunshine in the background..."
    nohup sunshine >/dev/null 2>&1 &
    
    echo "Turning off laptop screen..."
    brightnessctl set 0
end
