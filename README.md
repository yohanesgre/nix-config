# Nix Configuration

My personal [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) configuration for managing dotfiles and packages across Linux and macOS.

## 📚 Documentation

- **[docs/GUIDE.md](docs/GUIDE.md)** - User guide (profiles, platform setup)
- **[docs/REFERENCE.md](docs/REFERENCE.md)** - Technical reference (architecture, packages)
- **[docs/ADVANCED.md](docs/ADVANCED.md)** - Advanced topics (Flutter, secrets, auto-run)

## Features

- **Cross-platform support**: Works on Linux (x86_64, ARM64) and macOS (Intel, Apple Silicon)
- **Declarative package management**: All packages and configurations in one place
- **Consistent environment**: Same setup across all devices
- **Git-based dotfiles**: Version-controlled configuration
- **Automated SSH setup**: Script for easy SSH key generation and GitHub integration
- **Environment-based configuration**: Use Nix expressions for easy feature toggling

## What's Included

### Packages
- **Development**: git, gh (GitHub CLI), vim, vscode, claude-code
- **Shell**: zsh with oh-my-zsh, starship prompt, fzf
- **Terminal**: ghostty
- **System tools**: btop, fastfetch, nix-index
- **Fonts**: Nerd Fonts (FiraCode, JetBrains Mono, Meslo LG)
- **Wayland/Hyprland (Linux)**: hyprland, waybar, rofi-wayland, swaync, swww, grim, slurp, swappy
- **Linux-only**: flatpak
- **Gaming (optional)**: steam, wine, protontricks (Linux only)

### Programs Configured
- **Git**: User info and settings
- **SSH**: GitHub/GitLab ready, security-focused config
- **Zsh**: Auto-suggestions, syntax highlighting, history search
- **Starship**: Beautiful prompt with Catppuccin Mocha theme
- **Hyprland** (Linux): Fully declarative Wayland window manager with Material Design 3 theme
  - **Configuration**: All settings managed in `hyprland.nix` (250+ keybindings, window rules, animations)
  - **Waybar**: Status bar with system monitoring and power management
  - **Rofi**: Application launcher with Material Design theme
  - **SwayNC**: Notification center with custom styling
  - **Screenshots**: Grim + Slurp + Swappy for annotated screenshots
  - **Wallpapers**: SWWW for smooth wallpaper transitions with cycling/picker scripts

### Scripts
- `setup-ssh-key`: Interactive SSH key setup for GitHub
- `fix-royuan-keyboard` (Linux): Fix for ROYUAN OLV75 keyboard
- `setup-rapl-permissions` (Linux): Setup CPU power monitoring permissions
- `install-arch-packages` (Linux): Install system packages via pacman
- `setup-android-sdk` (Optional): Android SDK setup for Flutter development

### Hyprland Scripts
- `wallpaper.sh`: Set wallpaper with SWWW (supports random selection)
- `wallpaper-cycle.sh`: Cycle through wallpapers (Super + Alt + W)
- `wallpaper-picker.sh`: Pick wallpaper via Rofi (Super + Shift + W)
- `display-picker.sh`: Switch display resolution (Super + Shift + D)
- `power-monitor.sh`: Waybar power monitoring (CPU, battery)
- `power-profile.sh`: Waybar power profile switcher

## Installation

### Prerequisites

#### 1. Install Nix with flakes support

```bash
# On Linux or macOS
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (add to ~/.config/nix/nix.conf or /etc/nix/nix.conf)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

#### 2. Install Home Manager (Standalone)

```bash
# Add the Home Manager channel (matching your Nix version)
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# Install Home Manager
nix-shell '<home-manager>' -A install
```

**Note**: For flake-based configuration (recommended), Home Manager will be installed automatically from the flake.

### Setup

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/nix-config.git ~/.config/nix
   cd ~/.config/nix
   ```

2. **Customize configuration** (edit `config.nix`):
   ```nix
   {
     # Enable optional features
     enableFlutter = true;
     enableGaming = true;
   }
   ```

3. **Set up Git user info** (add to `~/.zshrc` or create `~/.zshrc.local`):
   ```bash
   export GIT_AUTHOR_EMAIL="your-email@example.com"
   export GIT_AUTHOR_NAME="Your Name"
   export GIT_COMMITTER_EMAIL="your-email@example.com"
   export GIT_COMMITTER_NAME="Your Name"
   ```

4. **Apply the configuration**:
   ```bash
   # On Linux x86_64 (default)
   home-manager switch --flake ~/.config/nix#default

   # On Linux ARM64
   home-manager switch --flake ~/.config/nix#archlinux-arm

   # On macOS Intel
   home-manager switch --flake ~/.config/nix#macos-intel

   # On macOS ARM (Apple Silicon)
   home-manager switch --flake ~/.config/nix#macos
   ```

## Available Profiles

- `archlinux` - x86_64 Arch Linux
- `archlinux-arm` - ARM64 Arch Linux
- `macos` - ARM64 macOS (Apple Silicon)
- `macos-intel` - x86_64 macOS (Intel)
- `default` - x86_64 Arch Linux (same as `archlinux`)

## SSH Key Setup

After installation, set up SSH keys for GitHub:

```bash
setup-ssh-key
```

The script will:
- Prompt for a device name
- Generate an ed25519 SSH key
- Add it to GitHub automatically
- Test the connection

## Useful Aliases

Defined in the configuration:

- `hm` - Apply Home Manager configuration (`home-manager switch --flake ~/.config/nix#default`)
- `hme` - Edit home.nix
- `c` - Clear terminal
- Linux: `update`, `cleanup`, `jctl`, `rip`
- macOS: `update` (brew)

## Configuration Options

All optional features can be enabled/disabled in `config.nix`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enableFlutter` | boolean | `false` | Install Flutter SDK, Android Studio, and JDK 17 |
| `enableGaming` | boolean | `false` | Install Steam, Wine, and gaming tools (Linux only) |
| `flutterSdkUrl` | string | Latest stable | Flutter SDK download URL |
| `androidCmdlineToolsUrl` | string | Latest Linux tools | Android SDK command-line tools download URL |

See [docs/ADVANCED.md](docs/ADVANCED.md) for Flutter-specific setup instructions.

### Git Configuration

Git user information is configured via environment variables in your shell:

```bash
# Add to ~/.zshrc or ~/.zshrc.local
export GIT_AUTHOR_EMAIL="your-email@example.com"
export GIT_AUTHOR_NAME="Your Name"
export GIT_COMMITTER_EMAIL="your-email@example.com"
export GIT_COMMITTER_NAME="Your Name"
```

This keeps your personal git information out of version control while allowing git to use these values automatically.

## File Structure

```
.
├── flake.nix                   # Main flake configuration
├── flake.lock                  # Locked dependencies
├── home.nix                    # Home Manager configuration
├── hyprland.nix                # Declarative Hyprland configuration (all WM settings)
├── config.nix                  # User configuration file
├── nix.conf                    # Nix daemon settings
├── README.md                   # This file
├── .gitignore                  # Git ignore rules
├── docs/                       # Documentation
│   ├── GUIDE.md                # User guide
│   ├── REFERENCE.md            # Technical reference
│   └── ADVANCED.md             # Advanced topics
├── scripts/                    # Helper scripts
│   ├── setup-ssh-key.sh
│   ├── fix-royuan-keyboard.sh
│   ├── setup-rapl-permissions.sh
│   ├── setup-android-sdk.sh
│   └── install-arch-packages.sh
└── dotfiles/                   # Dotfiles configuration
    ├── hypr/                   # Hyprland resources
    │   ├── wallpapers/         # Wallpaper images
    │   └── scripts/            # Hyprland helper scripts
    ├── waybar/                 # Waybar configuration
    │   ├── config.jsonc        # Waybar modules
    │   ├── style.css           # Waybar styling
    │   └── scripts/            # Waybar scripts
    ├── rofi/                   # Rofi launcher
    │   └── config.rasi         # Material Design theme
    ├── swaync/                 # Notification center
    │   ├── config.json         # SwayNC settings
    │   └── style.css           # SwayNC styling
    ├── swaylock/               # Screen locker
    │   └── config
    ├── swayidle/               # Idle manager
    │   └── config
    ├── swappy/                 # Screenshot editor
    │   └── config
    └── wlogout/                # Logout menu
        ├── layout
        └── style.css
```

**Note**: All Hyprland configuration (keybindings, window rules, appearance, etc.) is now managed declaratively in `hyprland.nix` for better version control and maintainability.

## Updating & Rebuilding

### Update Flake Inputs (nixpkgs, home-manager, etc.)

```bash
# Update all flake inputs to latest versions
nix flake update ~/.config/nix

# Update specific input only
nix flake lock --update-input nixpkgs ~/.config/nix
nix flake lock --update-input home-manager ~/.config/nix
```

### Rebuild After Configuration Changes

```bash
# After editing home.nix, config.nix, or any configuration files
# Linux (x86_64)
home-manager switch --flake ~/.config/nix#archlinux

# Linux (ARM64)
home-manager switch --flake ~/.config/nix#archlinux-arm

# macOS (Apple Silicon)
home-manager switch --flake ~/.config/nix#macos

# macOS (Intel)
home-manager switch --flake ~/.config/nix#macos-intel

# Or use the alias (configured for your platform)
hm
```

### Refresh/Rebuild Without Changes

```bash
# Force rebuild even if nothing changed
home-manager switch --flake ~/.config/nix#archlinux --refresh

# Or clear the build cache and rebuild
nix-collect-garbage
home-manager switch --flake ~/.config/nix#archlinux
```

## Hyprland Keybindings (Linux)

### Applications
- `Super + Return` - Launch terminal (Ghostty)
- `Super + D` - Application launcher (Rofi)
- `Super + E` - File manager (Dolphin)
- `Super + B` - Browser (Zen)
- `Super + W` - Close active window
- `Super + V` - Toggle floating
- `Super + F` - Toggle fullscreen
- `Super + Space` - Vicinae toggle

### Window Management
- `Super + Arrow Keys` - Move focus
- `Super + Shift + Arrow Keys` - Move window
- `Super + Ctrl + Arrow Keys` - Resize window
- `Super + J` - Toggle split
- `Super + P` - Pseudo-tiling
- `Super + Mouse Left/Right` - Move/Resize window

### Workspaces
- `Super + 1-9` - Switch to workspace
- `Super + Shift + 1-9` - Move window to workspace
- `Super + S` - Toggle scratchpad
- `Super + Shift + S` - Move to scratchpad
- `Super + Mouse Scroll` - Cycle workspaces

### Screenshots
- `Print` - Full screen → Swappy (annotate)
- `Super + Print` - Area selection → Swappy (annotate)
- `Super + Shift + Print` - Area selection → Clipboard

### Wallpapers
- `Super + Shift + W` - Pick wallpaper (Rofi)
- `Super + Alt + W` - Cycle wallpaper

### System
- `Super + N` - Toggle notification center
- `Super + Shift + D` - Display resolution picker
- `Super + Shift + R` - Reload Hyprland + Waybar
- `Super + Shift + L` - Lock screen
- `Super + Escape` - Logout menu (wlogout)
- `Super + Shift + Escape` - Quick logout

### Media Keys
- Volume up/down/mute
- Brightness up/down
- Media play/pause/next/previous

## Platform-Specific Notes

### Linux (Arch/CachyOS)
- **Hybrid package management**: Essential packages via pacman, Nix-specific tools via Nix
- **Optimized for Arch**: Follows Arch Wiki best practices for Nix integration
- **Performance optimizations**: Multi-core builds, locale fixes
- Includes flatpak with auto-updates
- Optional gaming packages (Steam, Wine) via `enableGaming`
- CachyOS-inspired aliases and settings
- See [docs/REFERENCE.md](docs/REFERENCE.md) for package management strategy

### macOS
- **Full Nix package management**: All packages installed via Nix
- Automatically detects platform
- Uses appropriate CPU count for make/ninja
- Homebrew integration via alias
- No conflicts with system package managers

## Customization

1. **Add packages**: Edit `home.packages` in `home.nix`
2. **Platform-specific packages**: Use `lib.optionals isLinux` or `lib.optionals isDarwin`
3. **Add dotfiles**: Add entries to `home.file`
4. **Configure programs**: Add to `programs.*` sections

## Troubleshooting

**Dirty git tree warning**:
```bash
git add -A
git commit -m "Update configuration"
```

**File not tracked by Git**:
```bash
git add path/to/file
```

**SSH issues**:
- Ensure `gh` is authenticated: `gh auth login`
- Test connection: `ssh -T git@github.com`

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Nix Packages Search](https://search.nixos.org/packages)

## License

MIT
