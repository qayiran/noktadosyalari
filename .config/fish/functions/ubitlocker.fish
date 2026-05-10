function ubitlocker --description 'Safely unmounts and locks the Bitlocker drive'
    set -l decrypt_path "/mnt/bitlocker"
    set -l mount_path "$HOME/wan/bitlocker_mount"

    echo "Temizlik yapılıyor... Diski çıkarmayın."

    # 1. Unmount the user-accessible loop mount
    if mountpoint -q $mount_path
        echo "Disk sökülüyor..."
        sudo umount $mount_path
    else
        echo "Bindirilmiş bir yol bulunamadı."
    end

    # 2. Unmount the dislocker decryption layer
    if mountpoint -q $decrypt_path
        echo "Bitlocker taşıyıcısı kilitleniyor..."
        sudo umount $decrypt_path
    else
        # Sometimes dislocker needs a lazy unmount if FUSE is being stubborn
        sudo umount -l $decrypt_path 2>/dev/null
    end

    echo "Disk söküldü."
end
