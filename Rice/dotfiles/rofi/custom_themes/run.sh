#!/usr/bin/env bash

dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

highlight_colours=('#D370A3' '#6D9E3F' '#6095C5' '#B58858' '#3BA275' '#AC7BDE')
highlight="${highlight_colours[$(($RANDOM % ${#highlight_colours[@]}))]}ff"

sed -i "/highlight:/c\	highlight: $highlight;" $dir/colors.rasi

rofi -no-lazy-grab -show drun -modi drun -theme $dir/run_style.rasi

# Colours from here:
# http://dotshare.it/dots/274/
# al="#00000000"
# bg="#303030"
# fg="#CFCFCF"
# selected="#686868"