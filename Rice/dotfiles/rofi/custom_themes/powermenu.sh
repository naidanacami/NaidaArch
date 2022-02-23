#!/usr/bin/env bash
dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

highlight_colours=('#D370A3' '#6D9E3F' '#6095C5' '#B58858' '#3BA275' '#AC7BDE')
highlight="${highlight_colours[$(($RANDOM % ${#highlight_colours[@]}))]}ff"
sed -i "/highlight:/c\	highlight: $highlight;" $dir/colors.rasi

lock="Lock"
logout="Logout"
sleep="Sleep"
hibernate="Hibernate"
poweroff="Shutdown"
reboot="Reboot"

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
        betterlockscreen -l blur
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