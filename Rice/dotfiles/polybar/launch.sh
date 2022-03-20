#!/bin/bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch Polybar, using default config location ~/.config/polybar/config
#polybar mainbar 2>&1 | tee -a /tmp/polybar.log & disown
#polybar secondbar 2>&1 | tee -a /tmp/polybar.log & disown
polybar -r m1 &
polybar -r s1 &


echo "Polybar launched..."