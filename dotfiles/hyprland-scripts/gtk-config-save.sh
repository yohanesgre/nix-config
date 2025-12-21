#!/bin/bash
# Hyprland GTK Config Saver
# Saves current Hyprland GTK configs and restores Plasma's

# Save current configs as Hyprland-specific
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.hyprland 2>/dev/null
cp ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.hyprland 2>/dev/null
cp ~/.gtkrc-2.0 ~/.gtkrc-2.0.hyprland 2>/dev/null

# Restore Plasma configs
if [ -f ~/.config/gtk-3.0/settings.ini.plasma ]; then
    cp ~/.config/gtk-3.0/settings.ini.plasma ~/.config/gtk-3.0/settings.ini
fi

if [ -f ~/.config/gtk-4.0/settings.ini.plasma ]; then
    cp ~/.config/gtk-4.0/settings.ini.plasma ~/.config/gtk-4.0/settings.ini
fi

if [ -f ~/.gtkrc-2.0.plasma ]; then
    cp ~/.gtkrc-2.0.plasma ~/.gtkrc-2.0
fi
