#!/usr/bin/env fish

# We have to force standard English output here so grep actually works, 
# otherwise your localized system translates the headers! 🙄
set -x LANG C
set -x LC_ALL C

function print_header
    echo -e "\n\033[1;35m=== $argv ===\033[0m"
end

function print_item
    # Pads the label to 18 characters for beautiful alignment 🌸
    printf "  \033[1;36m%-18s\033[0m \033[1;37m%s\033[0m\n" "$argv[1]:" "$argv[2]"
end

print_header "💻 Processor (CPU)"
set cpu_vendor (lscpu | grep -i "Vendor ID:" | cut -d':' -f2 | string trim)
set cpu_model (lscpu | grep -i "Model name:" | cut -d':' -f2 | string trim)
print_item "Manufacturer" "$cpu_vendor"
print_item "Model" "$cpu_model"

print_header "🧩 Motherboard"
set mobo_mfg (:3 dmidecode -t baseboard 2>/dev/null | grep "Manufacturer:" | cut -d':' -f2 | string trim)
set mobo_prod (:3 dmidecode -t baseboard 2>/dev/null | grep "Product Name:" | cut -d':' -f2 | string trim)
print_item "Manufacturer" "$mobo_mfg"
print_item "Product" "$mobo_prod"

print_header "⚙️ BIOS / Firmware"
set bios_ven (:3 dmidecode -t bios 2>/dev/null | grep "Vendor:" | cut -d':' -f2 | string trim)
set bios_ver (:3 dmidecode -t bios 2>/dev/null | grep "Version:" | cut -d':' -f2 | string trim)
print_item "Vendor" "$bios_ven"
print_item "Version" "$bios_ver"

print_header "🧠 System Memory"
# Grabbing just the first valid RAM manufacturer so it doesn't spam the console!
set ram_mfg (:3 dmidecode -t memory 2>/dev/null | grep "Manufacturer:" | grep -v -i "Unknown" | grep -v -i "NO DIMM" | head -n 1 | cut -d':' -f2 | string trim)
set ram_size (free -h | awk '/^Mem:/ {print $2}')
set ram_speed (:3 dmidecode -t memory 2>/dev/null | grep "Speed:" | grep -v -i "Unknown" | head -n 1 | cut -d':' -f2 | string trim)
print_item "Manufacturer" "$ram_mfg"
print_item "Capacity" "$ram_size"
if test -n "$ram_speed"; print_item "Speed" "$ram_speed"; end

print_header "🎮 Graphics (GPU)"
set dgpu (lspci -nn | grep -i "vga" | grep -i "nvidia" | awk -F': ' '{print $2}' | string trim)
set igpu (lspci -nn | grep -i "vga" | grep -i "intel" | awk -F': ' '{print $2}' | string trim)
if test -n "$dgpu"; print_item "Dedicated" "$dgpu"; end
if test -n "$igpu"; print_item "Integrated" "$igpu"; end

print_header "🌐 Networking"
set wifi (lspci -nn | grep -i "network" | awk -F': ' '{print $2}' | string trim)
set eth (lspci -nn | grep -i "ethernet" | awk -F': ' '{print $2}' | string trim)
if test -n "$wifi"; print_item "Wi-Fi" "$wifi"; end
if test -n "$eth"; print_item "Ethernet" "$eth"; end

print_header "🦷 Bluetooth"
set bt_dev (lsusb | grep -i "bluetooth" | cut -d' ' -f7- | string trim)
if test -n "$bt_dev"
    print_item "Adapter" "$bt_dev"
else
    print_item "Adapter" "Not Found"
end

print_header "🔊 Audio"
set intel_aud (lspci | grep -i "audio" | grep -i "intel" | awk -F': ' '{print $2}' | string trim)
set nv_aud (lspci | grep -i "audio" | grep -i "nvidia" | awk -F': ' '{print $2}' | string trim)
if test -n "$intel_aud"; print_item "Intel Audio" "$intel_aud"; end
if test -n "$nv_aud"; print_item "NVIDIA Audio" "$nv_aud"; end

print_header "📷 Webcam / Video"
if test -e /sys/class/video4linux/video0/name
    print_item "Device" (cat /sys/class/video4linux/video0/name | string trim)
else
    print_item "Device" "Not Found"
end

print_header "💽 Storage Drives"
# Using lsblk is much safer, but we MUST filter out zram and loop devices! 😤
lsblk -d -o NAME,MODEL,SIZE | grep -E -v -i "(loop|zram|NAME)" | while read -l line
    set drive_name (echo $line | awk '{print $1}')
    set drive_model (echo $line | awk '{$1=""; $NF=""; print $0}' | string trim)
    set drive_size (echo $line | awk '{print $NF}')
    print_item "$drive_name" "$drive_model ($drive_size)"
end

print_header "📺 Display Panel"
set disp_make (hyprctl monitors | grep "make:" | cut -d':' -f2 | string trim)
set disp_model (hyprctl monitors | grep "model:" | cut -d':' -f2 | string trim)
# Stripping the ugly decimals from the refresh rate! 🌸
set disp_res (hyprctl monitors | grep -o "[0-9]*x[0-9]*@[0-9.]*" | head -n 1 | awk -F'.' '{print $1}')
if test -n "$disp_make"; print_item "Manufacturer" "$disp_make"; end
if test -n "$disp_model"; print_item "Model" "$disp_model"; end
if test -n "$disp_res"; print_item "Resolution" "$disp_res"; end

print_header "⌨️ Peripherals"
# Filtering out the boring root hubs!
lsusb | grep -v "Linux Foundation" | while read -l line
    set dev (echo $line | cut -d' ' -f7-)
    print_item "USB Device" "$dev"
end

print_header "🖲️ Touchpad (I2C)"
# Searching the kernel's input device records
set touchpad (grep -iA 5 "Touchpad" /proc/bus/input/devices 2>/dev/null | grep -i "Name=" | cut -d'"' -f2 | string trim)
if test -n "$touchpad"
    print_item "Model" "$touchpad"
else
    print_item "Model" "Unknown (Check libinput)"
end

print_header "🛡️ Security (TPM)"
# Checking the sysfs directory for the TPM chip
if test -d /sys/class/tpm/tpm0
    set tpm_ver (cat /sys/class/tpm/tpm0/tpm_version_major 2>/dev/null | string trim)
    print_item "Module" "Active (TPM $tpm_ver.0)"
else
    print_item "Module" "Not Found / Disabled in BIOS"
end

print_header "🔋 Battery & Power"
if test -f /sys/class/power_supply/BAT1/manufacturer
    print_item "Battery Mfg" (cat /sys/class/power_supply/BAT1/manufacturer | string trim)
    print_item "Battery Model" (cat /sys/class/power_supply/BAT1/model_name | string trim)
else if test -f /sys/class/power_supply/BAT0/manufacturer
    print_item "Battery Mfg" (cat /sys/class/power_supply/BAT0/manufacturer | string trim)
    print_item "Battery Model" (cat /sys/class/power_supply/BAT0/model_name | string trim)
end

if test -f /sys/class/power_supply/ADP1/online
    set ac_status (cat /sys/class/power_supply/ADP1/online)
    if test "$ac_status" -eq 1; print_item "AC Adapter" "Connected ⚡"; else; print_item "AC Adapter" "Disconnected 🔋"; end
else if test -f /sys/class/power_supply/AC/online
    set ac_status (cat /sys/class/power_supply/AC/online)
    if test "$ac_status" -eq 1; print_item "AC Adapter" "Connected ⚡"; else; print_item "AC Adapter" "Disconnected 🔋"; end
end
echo ""
