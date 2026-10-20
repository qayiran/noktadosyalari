function ezmount
    if test -z "$argv[1]"
        echo "B-baka! You forgot to tell me which disk! (Usage: ezmount sda1)"
        return 1
    end
    
    echo "Mounting /dev/$argv[1] just for you... n-not that I want to! 😳"
    :3 mkdir -p ~/wan/usb
    :3 mount -o uid=qayiran,gid=qayiran /dev/$argv[1] ~/wan/usb
    echo "Done! It's in ~/wan/usb! Don't forget to unmount it later! ✨"
end
