#!/bin/bash

# Wallpaper cycling script
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CURRENT_FILE="$HOME/.cache/current_wallpaper"

# Create directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$HOME/.cache"

# Get list of wallpapers
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort))

# Check if there are any wallpapers
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Wallpaper Cycle" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Get current wallpaper path
CURRENT=""
if [ -f "$CURRENT_FILE" ]; then
    CURRENT=$(cat "$CURRENT_FILE")
fi

# Find current index
CURRENT_INDEX=-1
for i in "${!WALLPAPERS[@]}"; do
    if [ "${WALLPAPERS[$i]}" = "$CURRENT" ]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Get next wallpaper (cycle to beginning if at end)
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPERS[@]} ))
NEXT_WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"

# Save current wallpaper
echo "$NEXT_WALLPAPER" > "$CURRENT_FILE"

# Apply wallpaper
~/.config/hypr/scripts/wallpaper.sh "$NEXT_WALLPAPER"

# Get just the filename for notification
FILENAME=$(basename "$NEXT_WALLPAPER")
notify-send "Wallpaper Cycle" "Now showing: $FILENAME" -t 3000
