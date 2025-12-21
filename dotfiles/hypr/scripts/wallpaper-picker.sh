#!/bin/bash

# Wallpaper picker script using rofi
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

# Create directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Get list of image files (follow symlinks with -L)
WALLPAPERS=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n" | sort)

# Check if there are any wallpapers
if [ -z "$WALLPAPERS" ]; then
    if command -v notify-send &> /dev/null && pgrep -x swaync &> /dev/null; then
        notify-send "Wallpaper Picker" "No wallpapers found in $WALLPAPER_DIR"
    fi
    exit 1
fi

# Show rofi menu to select wallpaper
SELECTED=$(echo "$WALLPAPERS" | rofi -dmenu -p "Select Wallpaper")

# Exit if nothing selected
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Set the wallpaper
~/.config/hypr/scripts/wallpaper.sh "$WALLPAPER_DIR/$SELECTED"

# Send notification (if notification daemon is running)
if command -v notify-send &> /dev/null && pgrep -x swaync &> /dev/null; then
    notify-send "Wallpaper Changed" "Applied: $SELECTED"
fi
