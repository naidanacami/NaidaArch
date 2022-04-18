#!/usr/bin/env bash
dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


lock=" Lock"
logout=" Logout"
sleep=" Sleep"
hibernate=" Hibernate"
poweroff=" Shutdown"
reboot=" Reboot"

# User confirmation
user_confirmation() {
	conf=$(rofi -dmenu\
		-i\
		-no-fixed-num-lines\
		-p "Proceed? [Y/n] : "\
		-theme $dir/confirm.rasi
    )
    if [[ $conf == "y" || $conf == "Y" || $conf == "yes" || $conf == "YES" ]]; then
        echo true
    else
        exit 0
    fi
}

case $(echo -e "$lock\n$logout\n$sleep\n$hibernate\n$poweroff\n$reboot" | rofi -theme $dir/powermenu_style.rasi -p "Uptime: $(uptime -p | sed -e 's/up //g')" -dmenu) in
    $lock)
        betterlockscreen -l blur -- --time-str="%I:%M:%S %p"
        ;;
        
    $logout)
        ans=$(user_confirmation &)
        if [[ $ans == true ]];then
            i3-msg exit
        fi
        ;;

    $sleep)
        ans=$(user_confirmation &)
        if [[ $ans == true ]];then
            systemctl suspend
        fi
        ;;

    $hibernate)
        ans=$(user_confirmation &)
        if [[ $ans == true ]];then
            systemctl hibernate
        fi
        ;;
                
    $poweroff)
        ans=$(user_confirmation &)
        if [[ $ans == true ]];then
			systemctl poweroff
        fi
        ;;

    $reboot)
        ans=$(user_confirmation &)
        if [[ $ans == true ]];then
			systemctl reboot
        fi
        ;;
        
esac