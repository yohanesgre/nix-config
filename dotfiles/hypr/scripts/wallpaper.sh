#!/bin/bash

# Wallpaper and theme management script for Hyprland
# Uses swww for wallpaper and matugen for theming

WALLPAPER_PATH="$1"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# If no argument provided, use the default wallpaper
if [ -z "$WALLPAPER_PATH" ]; then
    WALLPAPER_PATH="$HOME/Downloads/pexels-simon73-1183099.jpg"
fi

# Check if swww daemon is running
if ! pgrep -x swww-daemon > /dev/null; then
    echo "Starting swww daemon..."
    swww-daemon &
    sleep 1
fi

# Set the wallpaper with swww
echo "Setting wallpaper: $WALLPAPER_PATH"
swww img "$WALLPAPER_PATH" \
    --transition-type wipe \
    --transition-duration 2 \
    --transition-fps 60 \
    --transition-angle 30

# Generate theme colors with matugen
if [ -f "$WALLPAPER_PATH" ]; then
    echo "Generating color scheme..."
    ~/.config/matugen/generate-theme.sh "$WALLPAPER_PATH"
fi

echo "Wallpaper and theme applied successfully!"

# Send notification
FILENAME=$(basename "$WALLPAPER_PATH")
notify-send "Wallpaper" "Applied: $FILENAME" -t 2000
