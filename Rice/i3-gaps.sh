#!/usr/bin/env bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


# Requirements install
sudo pacman -S i3-gaps i3blocks i3status feh --noconfirm --needed       # i3 
sudo pacman -S numlockx --noconfirm --needed       # Apps


# i3 SETUP
mkdir ~/.config/i3/
declare -i connected_monitors=( $(xrandr | grep " connected " | tr -cd '\n' | wc -c) )

if [[ $connected_monitors == 2 ]]; then                                                                 # Dual monitor. User must declare which is the primary monitor. If there is no primary monitor, too bad
    declare -a outputs=( $(xrandr | grep " connected " | awk '{print $1}') )
    declare -i index=1
    declare -i pmon
    IFS=$'\n'

    echo "TWO MONITORS DETECTED!"

    # Echos all of the connected inputs
    for output in "${outputs[@]}"; do
        echo "$index - $output"
        index=index+1
    done

    # Gets user's primary monitor
    while true; do
        read -p "Please enter primary moniror (ex: 2): " pmon
        pmon=pmon-1
        if [[ "${outputs[$pmon]}" != "" ]]; then
            break
        fi
        echo "ERROR: Invalid input! Index out of range."
    done

    # Get primary and secondary monitor
    primary_monitor=${outputs[$pmon]}
    if [ $pmon == 0 ]; then
        secondary_monitor=${outputs[1]}
    elif [ $pmon == 1 ]; then
        secondary_monitor=${outputs[0]}
    else
        echo "Error finding secondary monitor"
        exit
    fi

    # Moves and edits i3 config
    if [ ! -d "~/.config/i3" ];then
        mkdir -p ~/.config/i3
    fi
    cp $script_dir/dotfiles/i3/config_dualmonitor ~/.config/i3/config

    sed -i "s/set \$m2 --monitor2--/set \$m2 $secondary_monitor/" ~/.config/i3/config
    sed -i "s/set \$m1 --monitor1--/set \$m1 $primary_monitor/" ~/.config/i3/config


elif [[ $connected_monitors == 1 ]]; then                                                               # If there are more than one monitor, primary does not need to be set
    echo "ONE MONITOR DETECTED!"
    output=( $(xrandr | grep " connected " | awk '{print $1}') )

    # Moves and edits i3 config
    if [ ! -d "~/.config/i3" ];then
        mkdir -p ~/.config/i3
    fi
    cp $script_dir/dotfiles/i3/config_singlemonitor ~/.config/i3/config
    sed -i "s/set \$m1 --monitor--/set \$m1 $output/" ~/.config/i3/config		    # Replaces all commented hooks with a placeholder so the next command won't uncomment all of them

elif [[ $connected_monitors > 2 ]]; then                                                            # No config will be made by this script (i am lazy)
    echo "WARNING: more than 2 monitors detected! You will have to make you own config"
fi


# Wallpaper
yay -S ttf-cascadia-code --needed --noconfirm
mkdir -p ~/media/Wallpapers/
cp $script_dir/dotfiles/i3/set_random_wallpaper.sh ~/.config/i3/
chmod +x ~/.config/i3/set_random_wallpaper.sh


# rofi
sudo pacman -S rofi --noconfirm --needed
cp -r $script_dir/dotfiles/rofi ~/.config/
chmod +x ~/.config/rofi/custom_themes/powermenu.sh
chmod +x ~/.config/rofi/custom_themes/run.sh
chmod +x ~/.config/rofi/custom_themes/window.sh


# Lock
yay -S betterlockscreen --noconfirm
mkdir ~/.config/betterlockscreen
cp $script_dir/dotfiles/betterlockscreen/run.sh ~/.config/betterlockscreen/
chmod +x ~/.config/betterlockscreen/run.sh


# bar
yay -S polybar --noconfirm