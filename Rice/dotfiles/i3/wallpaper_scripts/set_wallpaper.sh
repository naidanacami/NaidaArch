#!/usr/bin/env bash
store_wallpaper="./current_wallpaper.txt"

wallpaper=$(cat ./$store_wallpaper)
feh --bg-fill $wallpaper
betterlockscreen -u $wallpaper
