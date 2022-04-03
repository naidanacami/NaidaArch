#!/usr/bin/env bash

dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


rofi -no-lazy-grab -show drun -modi drun -theme $dir/run_style.rasi