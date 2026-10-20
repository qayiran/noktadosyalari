function ezumount
    if test -z "$argv[1]"
        echo "B-baka! You have to tell me what to unmount! (Usage: ezumount sda1)"
        return 1
    end
    
    echo "Safely unmounting /dev/$argv[1]... You better have closed all your files in yazi! 🙄"
    :3 umount /dev/$argv[1]
    
    echo "All done! You can unplug it now! ...T-That sounded weird! Just take your drive and go! 😳✨"
end
