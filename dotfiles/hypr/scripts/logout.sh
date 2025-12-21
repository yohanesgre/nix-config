#!/bin/bash

# Clean up all Hyprland-related environment variables from systemd
systemctl --user unset-environment HYPRLAND_INSTANCE_SIGNATURE
systemctl --user unset-environment XDG_CURRENT_DESKTOP
systemctl --user unset-environment XDG_SESSION_DESKTOP
systemctl --user unset-environment WAYLAND_DISPLAY

# Stop hyprsession if it's running
systemctl --user stop hyprsession.service 2>/dev/null

# Exit Hyprland
hyprctl dispatch exit
