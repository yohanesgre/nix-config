#!/bin/bash

# Display resolution picker using rofi
# Automatically detect the active monitor
MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

choice=$(echo -e "2K (2560x1440) 1x\n2K (2560x1440) 1.5x\n2K (2560x1440) 2x\n4K (3840x2160) 1x\n4K (3840x2160) 1.5x\n4K (3840x2160) 2x" | rofi -dmenu -p "Select Resolution")

case "$choice" in
    "2K (2560x1440) 1x")
        hyprctl keyword monitor $MONITOR,2560x1440@60,0x0,1
        ;;
    "2K (2560x1440) 1.5x")
        hyprctl keyword monitor $MONITOR,2560x1440@60,0x0,1.5
        ;;
    "2K (2560x1440) 2x")
        hyprctl keyword monitor $MONITOR,2560x1440@60,0x0,2
        ;;
    "4K (3840x2160) 1x")
        hyprctl keyword monitor $MONITOR,3840x2160@60,0x0,1
        ;;
    "4K (3840x2160) 1.5x")
        hyprctl keyword monitor $MONITOR,3840x2160@60,0x0,1.5
        ;;
    "4K (3840x2160) 2x")
        hyprctl keyword monitor $MONITOR,3840x2160@60,0x0,2
        ;;
esac
