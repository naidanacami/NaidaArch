#!/usr/bin/env bash

if [[ -z $1 ]]; then 
    echo "Error: Please pass directory to wallpapers!"
    exit
fi

#file=$(find $1 -type f | shuf -n 1 | awk -F "/" '{print $NF}')
file_dir=$(find $1 -type f | shuf -n 1)

feh --bg-fill $file_dir