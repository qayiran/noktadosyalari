function uusb --wraps="sudo umount ~/wan/usb; and echo 'Güvënli bir şekilde çıkarıldı!'" --description "alias uusb=sudo umount ~/wan/usb; and echo 'Güvënli bir şekilde çıkarıldı!'"
    sudo umount ~/wan/usb; and echo 'Güvënli bir şekilde çıkarıldı!' $argv
end
