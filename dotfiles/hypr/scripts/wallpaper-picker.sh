#!/bin/bash

# Wallpaper picker script using wofi
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Create directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Get list of image files
WALLPAPERS=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n" | sort)

# Check if there are any wallpapers
if [ -z "$WALLPAPERS" ]; then
    notify-send "Wallpaper Picker" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Show wofi menu to select wallpaper
SELECTED=$(echo "$WALLPAPERS" | wofi --dmenu --prompt "Select Wallpaper" --height 400 --width 600)

# Exit if nothing selected
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Set the wallpaper
~/.config/hypr/scripts/wallpaper.sh "$WALLPAPER_DIR/$SELECTED"

# Send notification
notify-send "Wallpaper Changed" "Applied: $SELECTED"
