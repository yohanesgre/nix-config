#!/bin/bash
# Hyprland GTK Config Loader
# Saves Plasma's GTK configs and loads Hyprland-specific ones

# Backup current (Plasma) configs
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.plasma 2>/dev/null
cp ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.plasma 2>/dev/null
cp ~/.gtkrc-2.0 ~/.gtkrc-2.0.plasma 2>/dev/null

# Load Hyprland configs if they exist, otherwise copy from Plasma
if [ -f ~/.config/gtk-3.0/settings.ini.hyprland ]; then
    cp ~/.config/gtk-3.0/settings.ini.hyprland ~/.config/gtk-3.0/settings.ini
else
    # First time setup - use current config as Hyprland base
    cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.hyprland
fi

if [ -f ~/.config/gtk-4.0/settings.ini.hyprland ]; then
    cp ~/.config/gtk-4.0/settings.ini.hyprland ~/.config/gtk-4.0/settings.ini
else
    cp ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.hyprland
fi

if [ -f ~/.gtkrc-2.0.hyprland ]; then
    cp ~/.gtkrc-2.0.hyprland ~/.gtkrc-2.0
else
    cp ~/.gtkrc-2.0 ~/.gtkrc-2.0.hyprland
fi

# Apply nwg-look settings if configured
if command -v nwg-look &> /dev/null; then
    nwg-look -a 2>/dev/null
fi
