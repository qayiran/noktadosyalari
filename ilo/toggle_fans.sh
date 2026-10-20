#!/bin/bash

# Paths
CB_PATH="/sys/devices/platform/msi-ec/cooler_boost"
MODE_PATH="/sys/devices/platform/msi-ec/fan_mode"

# Get current states
CB_STATUS=$(cat $CB_PATH)
MODE_STATUS=$(cat $MODE_PATH)

if [ "$CB_STATUS" = "on" ]; then
    # If Cooler Boost is on, turn it off and go to Auto
    echo "off" | sudo tee $CB_PATH > /dev/null
    echo "auto" | sudo tee $MODE_PATH > /dev/null
    notify-send -u low "Fanlar" "Mod: Oto 🤖"
elif [ "$MODE_STATUS" = "auto" ]; then
    # If Auto, go to Silent
    echo "silent" | sudo tee $MODE_PATH > /dev/null
    notify-send -u low "Fanlar" "Mod: Sessiz 🤫"
else
    # If Silent or anything else, go to Cooler Boost
    echo "on" | sudo tee $CB_PATH > /dev/null
    notify-send -u critical "Fanlar" "Mod: SOĞUTMA TAKVİYESİ 🌪️"
fi
