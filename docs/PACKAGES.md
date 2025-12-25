# Package Management

This document details all packages managed by this configuration.

## Package Management Strategy

### Linux (Arch/CachyOS)
**Hybrid approach** - split between Nix and pacman:

> **Note**: This configuration supports dual desktop environments (Hyprland + KDE Plasma).
> - Hyprland-specific packages managed via `install-arch-packages.sh`
> - KDE Plasma packages (dolphin, polkit-kde-agent, etc.) managed separately
> - Shared packages: Qt Wayland, system utilities

- **Nix packages** (in `home.nix`):
  - Nix-exclusive tools: `claude-code`, `nix-index`
  - CLI tools: `git`, `curl`, `vim`, `btop`, `fzf`, `yazi`, etc.
  - Development tools: `gh`, `tmux`, `zoxide`
  - Wayland utilities: `wl-clipboard`, `grim`, `slurp`, `cliphist`
  - Fonts: Nerd Fonts (FiraCode, JetBrains Mono, Meslo LG)

- **Pacman packages** (via `install-arch-packages.sh`):
  - System packages: `flatpak`, `base-devel`
  - Hyprland ecosystem: `hyprland`, `waybar`, `rofi-wayland`, `swaync`, `swww`
  - GUI applications: `nautilus`, `ghostty` (AUR), `vscode` (AUR)
  - Desktop integration: `polkit-gnome`, `gvfs`, `file-roller`
  - Qt compatibility: `qt5-wayland`, `qt6-wayland`, `qt6ct`
  - Optional: Gaming packages (Steam, Wine, Protontricks)

### macOS
**Full Nix management** - all packages via Nix:
- All CLI tools, GUI apps, and fonts installed through Nix
- No pacman equivalent, so everything is managed declaratively

## Core Packages

### Development Tools
| Package | Linux (Nix) | macOS (Nix) | Description |
|---------|-------------|-------------|-------------|
| `claude-code` | ✓ | ✓ | AI-powered coding assistant |
| `git` | ✓ | ✓ | Version control |
| `gh` | ✓ | ✓ | GitHub CLI |
| `vim` | ✓ | ✓ | Text editor |
| `vscode` | AUR | ✓ | Visual Studio Code |
| `tmux` | ✓ | ✓ | Terminal multiplexer |

### System Utilities
| Package | Linux (Nix) | macOS (Nix) | Description |
|---------|-------------|-------------|-------------|
| `btop` | ✓ | ✓ | Resource monitor |
| `fastfetch` | ✓ | ✓ | System information |
| `nix-index` | ✓ | ✓ | Nix package search |
| `fzf` | ✓ | ✓ | Fuzzy finder |
| `yazi` | ✓ | - | TUI file manager |
| `zoxide` | ✓ | - | Smart cd |

### Wayland/Hyprland (Linux only)

#### Window Manager & Desktop
| Package | Source | Description |
|---------|--------|-------------|
| `hyprland` | pacman | Wayland compositor |
| `waybar` | pacman | Status bar |
| `rofi-wayland` | pacman | Application launcher |
| `swaync` | pacman | Notification center |
| `wlogout` | pacman | Logout menu |
| `hypridle` | pacman | Idle management daemon |
| `hyprlock` | pacman | Screen locker |
| `hyprsession` | AUR | Session manager |

#### File Management
| Package | Source | Description |
|---------|--------|-------------|
| `nautilus` | pacman | GNOME file manager |
| `gvfs` | pacman | Virtual filesystem support |
| `gvfs-mtp` | pacman | Android device support |
| `gvfs-gphoto2` | pacman | Camera support |
| `file-roller` | pacman | Archive manager |

#### Utilities
| Package | Source | Description |
|---------|--------|-------------|
| `polkit-gnome` | pacman | Authentication agent |
| `brightnessctl` | pacman | Brightness control |
| `pwvucontrol` | pacman | PipeWire volume control GUI |
| `swww` | pacman | Wallpaper daemon |
| `swappy` | pacman | Screenshot annotation |

#### Wayland CLI Tools (Nix)
| Package | Description |
|---------|-------------|
| `wl-clipboard` | Wayland clipboard utilities |
| `grim` | Screenshot tool |
| `slurp` | Region selector |
| `cliphist` | Clipboard history |

#### Qt Compatibility
| Package | Source | Description |
|---------|--------|-------------|
| `qt5-wayland` | pacman | Qt5 Wayland support |
| `qt6-wayland` | pacman | Qt6 Wayland support |
| `qt6ct` | pacman | Qt6 theme configuration tool |

### Fonts
All via Nix on both platforms:
- `nerd-fonts.fira-code`
- `nerd-fonts.jetbrains-mono`
- `nerd-fonts.meslo-lg`
- `font-awesome` (Linux only)

### Terminal & Shell
| Package | Linux | macOS | Source | Description |
|---------|-------|-------|--------|-------------|
| `ghostty` | ✓ | ✓ | AUR/Nix | GPU-accelerated terminal |
| `zsh` | System | Nix | - | Shell (configured via Home Manager) |
| `starship` | Nix | Nix | - | Prompt (via Home Manager) |

### Optional Features

#### Gaming (Linux, via `enableGaming`)
Installed via `install-arch-packages.sh`:
- `steam`
- `wine`
- `winetricks`
- `protontricks`

#### Flutter Development (via `enableFlutter`)
Nix packages:
- `jdk17` (both platforms)
- `libglvnd` (Linux only)

Scripts handle:
- Android SDK installation
- Flutter SDK installation

## AUR Packages (Linux)

Installed via `install-arch-packages.sh`:
- `visual-studio-code-bin`
- `ghostty`
- `matugen` - Color theme generator
- `alacritty` - Alternative terminal
- `vicinae-bin` - TUI tool
- `dracula-gtk-theme`
- `dracula-icons-git`
- `nwg-look` - GTK theme selector
- `discord` - With custom app.asar support
- `hyprsession`

## Flatpak Applications

System flatpak (managed via pacman), applications:
- `io.github.zen_browser.zen` - Zen Browser

## Managing Packages

### Add a Nix Package
Edit `home.nix`:
```nix
home.packages = with pkgs; [
  # Add your package here
  neovim
];
```

### Add a Pacman Package (Linux)
Edit `scripts/install-arch-packages.sh`:
```bash
WAYLAND_PACKAGES=(
  # Add to appropriate array
  your-package
)
```

### Platform-Specific Packages
```nix
home.packages = with pkgs; [
  # Common packages
] ++ lib.optionals isLinux [
  # Linux-only
] ++ lib.optionals isDarwin [
  # macOS-only
];
```

### Search for Packages
```bash
# Nix packages
nix search nixpkgs package-name

# Arch packages
pacman -Ss package-name

# AUR packages
yay -Ss package-name
```

## Package Update Strategy

### Nix Packages
```bash
# Update flake inputs (nixpkgs)
nix flake update ~/.config/nix

# Apply updates
home-manager switch --flake ~/.config/nix#archlinux
```

### Pacman Packages (Linux)
```bash
# Update system packages
sudo pacman -Syu

# Update AUR packages
yay -Syu
```

### Flatpak
```bash
flatpak update
```
