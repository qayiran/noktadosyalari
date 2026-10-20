function mbitlocker --description 'Mounts a Bitlocker drive using native cryptsetup'
    # Check if the user provided a partition
    if test (count $argv) -lt 1
        echo "Diski belirtmelisiniz, örnek: mbitlocker /dev/sda2"
        return 1
    end

    set -l partition $argv[1]
    set -l mapper_name "bibbul_bitlocker"
    set -l mount_path "$HOME/wan/bitlocker_mount"

    # Create mount directory if it doesn't exist
    if not test -d $mount_path
        mkdir -p $mount_path
    end

    echo "Diskin şifresi çözülüyor (cryptsetup ile)..."
    
    # Step 1: Open the bitlocker volume
    :3 cryptsetup bitlkOpen $partition $mapper_name

    # Step 2: Mount if decryption was successful
    if test $status -eq 0
        echo "Şifre başarıyla çözüldü. Bindiriliyor..."
        # Mount the mapped drive using your user ID
        :3 mount -o uid=(id -u),gid=(id -g) /dev/mapper/$mapper_name $mount_path
        echo "Disk başarıyla bindirildi! ✨"
    else
        echo "Şifre çözülemedi. Baka!"
        return 1
    end
end
