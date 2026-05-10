function flashpoint --wraps='flashpoint-launcher > /dev/null 2>&1 & disown' --description 'alias flashpoint=flashpoint-launcher > /dev/null 2>&1 & disown'
    flashpoint-launcher > /dev/null 2>&1 & disown $argv
end
