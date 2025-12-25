# Hyprland Keybindings

Complete list of keyboard shortcuts for Hyprland window manager.

> **Note**: `Super` key = Windows key / Command key

## Applications

| Keybinding | Action |
|------------|--------|
| `Super + Return` | Launch terminal (Ghostty) |
| `Super + D` | Application launcher (Rofi) |
| `Super + E` | File manager (Nautilus) |
| `Super + B` | Browser (Zen) |
| `Super + Space` | Vicinae toggle |

## Window Management

| Keybinding | Action |
|------------|--------|
| `Super + W` | Close active window |
| `Super + V` | Toggle floating mode |
| `Super + F` | Toggle fullscreen |
| `Super + J` | Toggle split direction |
| `Super + P` | Pseudo-tiling mode |

### Focus Movement
| Keybinding | Action |
|------------|--------|
| `Super + ←` | Move focus left |
| `Super + →` | Move focus right |
| `Super + ↑` | Move focus up |
| `Super + ↓` | Move focus down |

### Window Movement
| Keybinding | Action |
|------------|--------|
| `Super + Shift + ←` | Move window left |
| `Super + Shift + →` | Move window right |
| `Super + Shift + ↑` | Move window up |
| `Super + Shift + ↓` | Move window down |

### Window Resizing
| Keybinding | Action |
|------------|--------|
| `Super + Ctrl + ←` | Resize window left (-40px) |
| `Super + Ctrl + →` | Resize window right (+40px) |
| `Super + Ctrl + ↑` | Resize window up (-40px) |
| `Super + Ctrl + ↓` | Resize window down (+40px) |

### Mouse Bindings
| Keybinding | Action |
|------------|--------|
| `Super + Left Click + Drag` | Move window |
| `Super + Right Click + Drag` | Resize window |

## Workspaces

### Switch Workspace
| Keybinding | Action |
|------------|--------|
| `Super + 1` | Switch to workspace 1 |
| `Super + 2` | Switch to workspace 2 |
| `Super + 3` | Switch to workspace 3 |
| `Super + 4` | Switch to workspace 4 |
| `Super + 5` | Switch to workspace 5 |
| `Super + 6` | Switch to workspace 6 |
| `Super + 7` | Switch to workspace 7 |
| `Super + 8` | Switch to workspace 8 |
| `Super + 9` | Switch to workspace 9 |
| `Super + 0` | Switch to workspace 10 |

### Move Window to Workspace
| Keybinding | Action |
|------------|--------|
| `Super + Shift + 1-0` | Move window to workspace 1-10 |

### Special Workspace (Scratchpad)
| Keybinding | Action |
|------------|--------|
| `Super + S` | Toggle scratchpad workspace |
| `Super + Shift + S` | Move window to scratchpad |

### Workspace Navigation
| Keybinding | Action |
|------------|--------|
| `Super + Mouse Scroll Up` | Next workspace |
| `Super + Mouse Scroll Down` | Previous workspace |

## Screenshots

| Keybinding | Action |
|------------|--------|
| `Print` | Full screen → Swappy (annotate) |
| `Super + Print` | Area selection → Swappy (annotate) |
| `Super + Shift + Print` | Area selection → Clipboard |

## Wallpapers

| Keybinding | Action |
|------------|--------|
| `Super + Shift + W` | Pick wallpaper (Rofi menu) |
| `Super + Alt + W` | Cycle to next wallpaper |

## System Controls

| Keybinding | Action |
|------------|--------|
| `Super + N` | Toggle notification center |
| `Super + Shift + D` | Display resolution picker |
| `Super + Shift + R` | Reload Hyprland + Waybar + SwayNC |
| `Super + Shift + L` | Lock screen (Hyprlock) |
| `Super + Escape` | Logout menu (wlogout) |
| `Super + Shift + M` | Exit Hyprland |

## Media Keys

### Audio
| Keybinding | Action |
|------------|--------|
| `XF86AudioRaiseVolume` | Volume up 5% |
| `XF86AudioLowerVolume` | Volume down 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |

### Brightness
| Keybinding | Action |
|------------|--------|
| `XF86MonBrightnessUp` | Brightness up 5% |
| `XF86MonBrightnessDown` | Brightness down 5% |

### Media Playback
| Keybinding | Action |
|------------|--------|
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioPause` | Play/Pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

## Idle Management

Configured via `hypridle` (no keybindings):
- **30 minutes** - Display off (DPMS)
- **35 minutes** - Lock session
- **60 minutes** - Suspend system

Control via custom Waybar module or:
```bash
# Configure idle scheduler
Super + Shift + I
```

## Custom Scripts

These keybindings execute custom scripts in `~/.config/hypr/scripts/`:

| Script | Keybinding | Purpose |
|--------|------------|---------|
| `wallpaper-picker.sh` | `Super + Shift + W` | Rofi wallpaper selector |
| `wallpaper-cycle.sh` | `Super + Alt + W` | Cycle wallpapers |
| `display-picker.sh` | `Super + Shift + D` | Resolution picker |

## Configuration Location

All keybindings are defined in:
```
~/.config/nix/hyprland.nix
```

Lines 267-371 in the `settings.bind`, `settings.bindm`, `settings.bindel`, and `settings.bindl` sections.

To customize, edit `hyprland.nix` and run:
```bash
home-manager switch --flake ~/.config/nix#archlinux
```

## Tips

### Learning Keybindings
- Start with window management basics: `Super + Arrow keys` (focus), `Shift + Arrow keys` (move)
- Master workspaces: `Super + 1-9` for quick switching
- Use scratchpad (`Super + S`) for temporary windows

### Common Workflows
1. **Quick screenshot**: `Super + Print` → select area → annotate in Swappy
2. **Organize windows**: `Super + 1-9` to spread across workspaces
3. **Focus mode**: `Super + F` for fullscreen, `Super + N` to hide notifications
4. **Change wallpaper**: `Super + Shift + W` for picker or `Super + Alt + W` to cycle

### Customization
To add or modify keybindings, edit the `bind` array in `hyprland.nix`:
```nix
bind = [
  "$mainMod, K, exec, your-command"
  # Add more bindings here
];
```
