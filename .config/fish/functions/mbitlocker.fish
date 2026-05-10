function mbitlocker --description 'Mounts a Bitlocker drive'
    # Check if the user provided a partition
    if test (count $argv) -lt 1
        echo "Diski belirtmelisiniz, örnek: mbitlocker /dev/sda1"
        return 1
    end

    set -l partition $argv[1]
    set -l decrypt_path "/mnt/bitlocker"
    set -l mount_path "$HOME/wan/bitlocker_mount"

    # Ensure the directories exist
    if not test -d $decrypt_path
        sudo mkdir -p $decrypt_path
    end
    if not test -d $mount_path
        mkdir -p $mount_path
    end

    # Step 1: Decrypt
    echo "Diskin şifresi çözülüyor..."
    sudo dislocker -V $partition -u -- $decrypt_path

    # Step 2: Mount if decryption was successful
    if test $status -eq 0
        echo "Şifre başarıyla çözüldü. Bindiriliyor..."
        sudo mount -o loop,uid=(id -u),gid=(id -g) $decrypt_path/dislocker-file $mount_path
        echo "Disk bindirildi."
    else
        echo "Şifre çözülemedi."
        return 1
    end
end
