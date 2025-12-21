#!/bin/bash

# Display resolution picker using rofi
# Automatically detect the active monitor
MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

choice=$(echo -e "2K (2560x1440)\n4K (3840x2160)" | rofi -dmenu -p "Select Resolution")

case "$choice" in
    "2K (2560x1440)")
        hyprctl keyword monitor $MONITOR,2560x1440@60,0x0,1
        ;;
    "4K (3840x2160)")
        hyprctl keyword monitor $MONITOR,3840x2160@60,0x0,1.5
        ;;
esac
