#!/usr/bin/env bash

# Power profile switcher for Waybar
# Supports power-profiles-daemon

get_profile() {
    if command -v powerprofilesctl &> /dev/null; then
        powerprofilesctl get
    else
        echo "balanced"
    fi
}

toggle_profile() {
    current=$(get_profile)

    case "$current" in
        "power-saver")
            powerprofilesctl set balanced
            ;;
        "balanced")
            powerprofilesctl set performance
            ;;
        "performance")
            powerprofilesctl set power-saver
            ;;
        *)
            powerprofilesctl set balanced
            ;;
    esac
}

get_tooltip() {
    case "$1" in
        "power-saver")
            echo "Power Saver - Battery life optimized"
            ;;
        "balanced")
            echo "Balanced - Standard performance"
            ;;
        "performance")
            echo "Performance - Maximum power"
            ;;
        *)
            echo "Unknown profile"
            ;;
    esac
}

if [ "$1" == "toggle" ]; then
    toggle_profile
else
    profile=$(get_profile)
    tooltip=$(get_tooltip "$profile")

    # Output JSON for Waybar
    echo "{\"text\":\"$profile\",\"tooltip\":\"$tooltip\",\"class\":\"$profile\",\"alt\":\"$profile\"}"
fi
