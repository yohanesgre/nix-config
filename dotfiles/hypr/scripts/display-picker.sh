#!/bin/bash

# Display resolution picker using wofi
choice=$(echo -e "2K (2560x1440)\n4K (3840x2160)" | wofi --dmenu --prompt "Select Resolution")

case "$choice" in
    "2K (2560x1440)")
        hyprctl keyword monitor DP-4,2560x1440@60,0x0,1
        ;;
    "4K (3840x2160)")
        hyprctl keyword monitor DP-4,3840x2160@60,0x0,1
        ;;
esac
