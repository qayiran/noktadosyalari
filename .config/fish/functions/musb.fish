function musb
    # 1. Show the partitions so you don't pick the wrong one
    echo "Sürücülër taranıyor..."
    lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL | grep --color=never "part"

    # 2. Ask for the name
    echo ""
    read -P "Hangi disk bölümü?: " part_name

    # 3. Check if the user actually typed something
    if test -z "$part_name"
        echo "Hiç bir şey belirtilmedi. Çıkılıyor."
        return 1
    end

    # 4. Do the mounting (The Magic Part)
    # We use id -u and id -g to make YOU the owner of the files
    sudo mount -o uid=(id -u),gid=(id -g) /dev/$part_name ~/wan/usb

    if test $status -eq 0
        echo "/dev/$part_name ~/wan/usb'ye bindirildi! Aça bilirsiniz."
    else
        echo "Başarısız olundu. Adı yanlış yazmış ola bilir misin?"
    end
end
