# Nix Configuration

Personal [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) configuration for managing dotfiles and packages across Linux and macOS.

## Overview

Cross-platform configuration that provides a consistent development environment with:
- **Declarative package management** - All packages and settings version-controlled
- **Hyprland setup** - Fully configured Wayland compositor with GTK/GNOME integration
- **Automated setup** - Scripts for SSH, system packages, and development environments
- **Platform detection** - Automatically adapts to Linux (Arch/CachyOS) or macOS

## Features

### Core
- **Zsh** with oh-my-zsh, starship prompt, syntax highlighting, autosuggestions
- **Development tools**: git, gh, vim, vscode, claude-code, tmux
- **System utilities**: btop, fastfetch, fzf, yazi, zoxide
- **Nerd Fonts**: FiraCode, JetBrains Mono, Meslo LG

### Hyprland (Linux)
Complete Wayland desktop environment with GTK/GNOME stack:
- **Window manager**: Hyprland with Material Design 3 theming
- **Desktop**: Waybar, Rofi, SwayNC, wlogout
- **File manager**: Nautilus with gvfs support
- **Screenshot tools**: grim, slurp, swappy
- **Wallpapers**: SWWW with cycling/picker scripts
- **Authentication**: polkit-gnome
- **Idle management**: hypridle + hyprlock

### Optional
- **Flutter development** - Android SDK + Flutter SDK automated setup
- **Gaming** - Steam, Wine, Protontricks (Linux)

## Quick Start

### Prerequisites

1. Install Nix with flakes:
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

2. Install Home Manager:
```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/nix-config.git ~/.config/nix
cd ~/.config/nix
```

2. Create `config.nix` (optional):
```nix
{
  # Git configuration
  gitUserName = "Your Name";
  gitUserEmail = "your-email@example.com";

  # Optional features
  enableFlutter = false;
  enableGaming = false;
  enableRoyuanKeyboard = false;
}
```

3. Apply configuration:
```bash
# Linux (Arch)
home-manager switch --flake ~/.config/nix#archlinux

# macOS (Apple Silicon)
home-manager switch --flake ~/.config/nix#macos

# Or use the alias after first install
hm
```

4. Setup SSH key (first time):
```bash
setup-ssh-key
```

## Available Profiles

- `archlinux` - x86_64 Arch Linux (default)
- `archlinux-arm` - ARM64 Arch Linux
- `macos` - ARM64 macOS (Apple Silicon)
- `macos-intel` - x86_64 macOS (Intel)

## Documentation

- **[docs/GUIDE.md](docs/GUIDE.md)** - Setup guide and user workflows
- **[docs/PACKAGES.md](docs/PACKAGES.md)** - Complete package list and management
- **[docs/KEYBINDINGS.md](docs/KEYBINDINGS.md)** - Hyprland keyboard shortcuts
- **[docs/REFERENCE.md](docs/REFERENCE.md)** - Architecture and technical details
- **[docs/ADVANCED.md](docs/ADVANCED.md)** - Flutter, secrets, advanced topics

## Quick Reference

### Common Commands
```bash
# Update and rebuild
hm                          # Apply configuration
hme                         # Edit home.nix

# Linux (Arch) package management
update                      # Update system packages
cleanup                     # Remove orphaned packages
```

### Hyprland Essentials
```bash
Super + Return              # Terminal
Super + D                   # App launcher
Super + E                   # File manager (Nautilus)
Super + W                   # Close window
Super + 1-9                 # Switch workspace
Super + Print               # Screenshot (area)
Super + Shift + W           # Pick wallpaper
```

See [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md) for complete list.

## File Structure

```
.
├── flake.nix              # Flake configuration
├── home.nix               # Main Home Manager config
├── hyprland.nix           # Hyprland WM configuration
├── config.nix             # User settings (git-ignored)
├── docs/                  # Documentation
│   ├── GUIDE.md
│   ├── PACKAGES.md
│   ├── KEYBINDINGS.md
│   ├── REFERENCE.md
│   └── ADVANCED.md
├── scripts/               # Setup and utility scripts
└── dotfiles/              # Application configs
    ├── hypr/              # Hyprland resources
    ├── waybar/
    ├── rofi/
    ├── swaync/
    └── wlogout/
```

## Platform-Specific Notes

### Linux (Arch/CachyOS)
- **Hybrid package management**: Nix for CLI tools, pacman for GUI apps and system packages
- First run automatically installs Arch packages via `install-arch-packages.sh`
- Hyprland configuration fully managed by Home Manager
- See [docs/PACKAGES.md](docs/PACKAGES.md) for package strategy

### macOS
- **Full Nix management**: All packages installed via Nix
- Automatic platform detection
- Homebrew integration via aliases

## Updating

```bash
# Update flake inputs (nixpkgs, home-manager)
nix flake update ~/.config/nix

# Apply updates
hm

# Linux: Update system packages
update    # sudo pacman -Syu
```

## Troubleshooting

**Dirty git tree warning**:
```bash
git add -A && git commit -m "Update configuration"
```

**Rebuild issues**:
```bash
nix-collect-garbage
home-manager switch --flake ~/.config/nix#archlinux --refresh
```

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Nix Packages Search](https://search.nixos.org/packages)
- [Hyprland Wiki](https://wiki.hyprland.org/)

## License

MIT
