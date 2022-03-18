#!/usr/bin/env bash
store_wallpaper="./current_wallpaper.txt"

# Check if wallpaper dir is passed
if [[ -z $1 ]]; then 
    echo "Error: Please pass directory to wallpapers!"
    exit
fi


#file=$(find $1 -type f | shuf -n 1 | awk -F "/" '{print $NF}')
file_dir=$(find $1 -type f | shuf -n 1)

# Checks if file exists
if [ ! -f "$store_wallpaper" ]; then
    touch $store_wallpaper
    cat <<EOF > $store_wallpaper
$file_dir
EOF
    exit 1
fi

# Gets a wallpaper that isn't the current one
current_wallpaper=$(cat $store_wallpaper)
while [[ "$current_wallpaper" == "$file_dir" ]]
do
    file_dir=$(find $1 -type f | shuf -n 1)
done

cat <<EOF > $store_wallpaper
$file_dir
EOF