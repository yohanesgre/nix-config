#!/bin/bash

# Wallpaper and theme management script for Hyprland
# Uses swww for wallpaper and matugen for theming

WALLPAPER_PATH="$1"
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

# If no argument provided, randomly select from wallpapers directory
if [ -z "$WALLPAPER_PATH" ]; then
    # Get array of wallpapers (follow symlinks with -L)
    WALLPAPERS=($(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null))

    # Check if wallpapers exist
    if [ ${#WALLPAPERS[@]} -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        if command -v notify-send &> /dev/null && pgrep -x swaync &> /dev/null; then
            notify-send "Wallpaper" "No wallpapers found in wallpapers directory" -t 3000
        fi
        exit 1
    fi

    # Select random wallpaper
    RANDOM_INDEX=$(( RANDOM % ${#WALLPAPERS[@]} ))
    WALLPAPER_PATH="${WALLPAPERS[$RANDOM_INDEX]}"
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

# Generate theme colors with matugen (if configured)
if [ -f "$WALLPAPER_PATH" ] && [ -f "$HOME/.config/matugen/generate-theme.sh" ]; then
    echo "Generating color scheme..."
    ~/.config/matugen/generate-theme.sh "$WALLPAPER_PATH"
fi

echo "Wallpaper and theme applied successfully!"

# Send notification (if notification daemon is running)
FILENAME=$(basename "$WALLPAPER_PATH")
if command -v notify-send &> /dev/null && pgrep -x swaync &> /dev/null; then
    notify-send "Wallpaper" "Applied: $FILENAME" -t 2000
fi
