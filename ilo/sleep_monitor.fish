#!/usr/bin/env fish

while true
    set current_time (date +%H%M)
    
    if test $current_time -ge 2200; or test $current_time -lt 0600
        # Time for bed, baka!
        hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'
        # Sleep for 60 seconds so it doesn't spam a million popups
        sleep 60
    end
    
    sleep 30
end
