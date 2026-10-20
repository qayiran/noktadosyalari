function templeos
    qemu-system-x86_64 \
    -hda ~/qayiran/ijo/TempleOS/templeos.qcow2 \
    -cdrom ~/qayiran/ijo/TempleOS/TOS_Supplemental1.ISO \
    -boot c \
    -m 512M \
    -audiodev pa,id=snd0 -machine pcspk-audiodev=snd0 \
    -enable-kvm \
    -display sdl \
    -k tr \
    &; disown
end
