#!/usr/bin/env bash


script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

declare -i connected_monitors=( $(xrandr | grep " connected " | tr -cd '\n' | wc -c) )

if [[ $connected_monitors == 2 ]]; then                                                                                             # Dual monitor. User must declare which is the primary monitor. If there is no primary monitor, too bad
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

    sed -i "s/set \$monitor_2 --monitor2--/set \$monitor_2 $secondary_monitor/" $script_dir/dotfiles/i3/config_dualmonitor
    sed -i "s/set \$monitor_1 --monitor1--/set \$monitor_1 $primary_monitor/" $script_dir/dotfiles/i3/config_dualmonitor

    if [ ! -d "~/.config/i3" ];then
        mkdir -p ~/.config/i3
    fi
    cp $script_dir/dotfiles/i3/config_dualmonitor ~/.config/i3/config

elif [[ $connected_monitors == 1 ]]; then                                                       # If there are more than one monitor, primary does not need to be set
    echo "ONE MONITOR DETECTED!"
    output=( $(xrandr | grep " connected " | awk '{print $1}') )
    sed -i "s/set \$monitor_1 --monitor--/set \$monitor_1 $output/" $script_dir/dotfiles/i3/config_singlemonitor		    # Replaces all commented hooks with a placeholder so the next command won't uncomment all of them

    if [ ! -d "~/.config/i3" ];then
        mkdir -p ~/.config/i3
    fi
    cp $script_dir/dotfiles/i3/config_singlemonitor ~/.config/i3/config

elif [[ $connected_monitors > 2 ]]; then                                                        # No config will be made by this script (i am lazy)
    echo "WARNING: more than 2 monitors detected! You will have to make you own config"

fi