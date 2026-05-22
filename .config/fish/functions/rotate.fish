function rotate
    set config_file ~/.config/hypr/hyprland.lua 
    set val $argv[1]

    # Check if you actually gave a valid number.
    if not string match -q -r '^[0-7]$' "$val"
        echo "Bana 0'dan 7'ye bir sayı vërmelisin!"
        return 1
    end

    # Use sed to find the transform line and swap the number.
    sed -i -E "s/transform\s*=\s*[0-7]/transform = $val/" $config_file

    echo "$val değeri uygulandı."
end
