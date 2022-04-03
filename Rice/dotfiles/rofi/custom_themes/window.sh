#!/usr/bin/env bash

dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

rofi -no-lazy-grab -show window -modi window -theme $dir/window_style.rasi