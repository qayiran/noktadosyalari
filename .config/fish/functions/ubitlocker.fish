function ubitlocker --description 'Safely unmounts and locks the Bitlocker drive via cryptsetup'
    set -l mount_path "$HOME/wan/bitlocker_mount"
    set -l mapper_name "bibbul_bitlocker"

    echo "Temizlik yapılıyor... Diski çıkarmayın."

    # 1. Unmount the file system
    if mountpoint -q $mount_path
        echo "Disk sökülüyor..."
        :3 umount $mount_path
    else
        echo "Bindirilmiş bir yol bulunamadı."
    end

    # 2. Lock the cryptsetup layer
    # We check if the block device actually exists before trying to close it
    if test -b "/dev/mapper/$mapper_name"
        echo "Bitlocker taşıyıcısı kilitleniyor..."
        :3 cryptsetup close $mapper_name
    else
        echo "Açık bir Bitlocker taşıyıcısı zaten yok."
    end

    echo "Disk söküldü ve kilitlendi. ✨"
end
