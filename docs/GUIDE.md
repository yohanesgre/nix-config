# Flake Profiles Guide

This configuration provides explicit flake profiles for different platforms.

## Available Profiles

### Primary Profiles (Recommended)

```bash
# Arch Linux x86_64
home-manager switch --flake ~/.config/nix#archlinux

# Arch Linux ARM64
home-manager switch --flake ~/.config/nix#archlinux-arm

# macOS Apple Silicon (M1/M2/M3)
home-manager switch --flake ~/.config/nix#macos

# macOS Intel
home-manager switch --flake ~/.config/nix#macos-intel

# Default (Arch Linux x86_64)
home-manager switch --flake ~/.config/nix#default
```

### Legacy Profiles (Backwards Compatibility)

```bash
# These still work but use the new names above
home-manager switch --flake ~/.config/nix#linux        # → archlinux
home-manager switch --flake ~/.config/nix#linux-arm    # → archlinux-arm
home-manager switch --flake ~/.config/nix#darwin       # → macos-intel
home-manager switch --flake ~/.config/nix#darwin-arm   # → macos
```

## Profile Differences

### `#archlinux` Profile

**Platform:** x86_64 Arch Linux / CachyOS

**Package Management:**
- Nix: claude-code, nix-index, fastfetch
- Pacman: git, curl, vim, fonts, GUI apps, zsh plugins

**Optimizations:**
- Arch Wiki recommendations
- Multi-core builds (`max-jobs = auto`)
- Locale fixes (`LOCALE_ARCHIVE`)
- Desktop integration (`XDG_DATA_DIRS`)

**Shell Aliases:**
- `update` → `sudo pacman -Syu`
- `cleanup` → Remove orphaned packages
- `rmpkg`, `cleanch`, `fixpacman`, `jctl`, `rip`

**Scripts:**
- `fix-royuan-keyboard` (hardware-specific)
- `install-arch-packages.sh` (package installer)

### `#macos` Profile

**Platform:** ARM64 macOS (Apple Silicon)

**Package Management:**
- Nix: Everything (git, curl, vim, fonts, GUI apps, zsh plugins, etc.)
- Homebrew: None (optional for user)

**Optimizations:**
- Native Nix package management
- Ghostty via Nix (no OpenGL issues on macOS)

**Shell Aliases:**
- `update` → `brew update && brew upgrade`
- CPU detection via `sysctl -n hw.ncpu`

**Scripts:**
- `setup-ssh-key` (common)

### `#macos-intel` Profile

**Platform:** x86_64 macOS (Intel)

Same as `#macos` profile but for Intel Macs.

### `#archlinux-arm` Profile

**Platform:** ARM64 Arch Linux

Same as `#archlinux` profile but for ARM64 systems.

## Quick Reference

| Profile | Platform | Nix Packages | System Packages |
|---------|----------|--------------|-----------------|
| `archlinux` | x86_64 Linux | 3 | 15+ via pacman |
| `archlinux-arm` | ARM64 Linux | 3 | 15+ via pacman |
| `macos` | ARM64 macOS | ~20 | 0 |
| `macos-intel` | x86_64 macOS | ~20 | 0 |

## Setting Your Default Profile

Update the `hm` alias in your profile:

**For Arch Linux:**
```bash
# Already set in home.nix
hm = "home-manager switch --flake ~/.config/nix#archlinux"
```

**For macOS:**
```bash
# Edit home.nix and change to:
hm = "home-manager switch --flake ~/.config/nix#macos"
```

## Why Explicit Profiles?

1. **Clarity** - `#archlinux` is clearer than `#linux`
2. **Intent** - Shows the target distribution/OS
3. **Platform-specific** - Each profile optimized for its platform
4. **Documentation** - Self-documenting flake outputs

## Checking Your Current Profile

```bash
# Check which profile you last used
ls -la ~/.local/state/nix/profiles/home-manager

# Or check the generation
home-manager generations
```

## Switching Between Profiles

You can switch between profiles anytime:

```bash
# Currently on Arch, switch to see macOS packages
home-manager switch --flake ~/.config/nix#macos

# Switch back to Arch
home-manager switch --flake ~/.config/nix#archlinux
```

**Note:** This only changes which packages are installed, it doesn't change your actual OS! Use the profile for your current platform.

## CI/CD and Automation

For scripts and automation, use explicit profiles:

```bash
#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    home-manager switch --flake ~/.config/nix#archlinux
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ $(uname -m) == "arm64" ]]; then
        home-manager switch --flake ~/.config/nix#macos
    else
        home-manager switch --flake ~/.config/nix#macos-intel
    fi
fi
```

## See Also

- [ARCHITECTURE.md](./ARCHITECTURE.md) - How profiles are implemented
- [PLATFORM_COMPATIBILITY.md](./PLATFORM_COMPATIBILITY.md) - Platform differences
- [README.md](./README.md) - General usage guide
# Platform Compatibility Guide

This Nix configuration is designed to work seamlessly on both **Linux (Arch/CachyOS)** and **macOS**, with platform-specific optimizations.

## Package Management Strategy

### macOS
- ✅ **All packages via Nix** - Full Nix package management
- ✅ No system package conflicts
- ✅ Consistent environment across macOS machines
- ✅ Works on both Intel and Apple Silicon

**Packages installed via Nix on macOS:**
- Core utilities: git, curl, vim, unzip, zip, xz
- Development tools: gh, btop, fzf
- Fonts: Nerd Fonts (FiraCode, JetBrains Mono, Meslo)
- Terminals: ghostty
- GUI apps: vscode
- Zsh plugins: autosuggestions, syntax-highlighting, history-substring-search
- Nix-specific: claude-code, nix-index

### Linux (Arch/CachyOS)
- ✅ **Hybrid approach** - Minimal Nix packages + system pacman packages
- ✅ Follows Arch Wiki best practices
- ✅ No conflicts between Nix and pacman
- ✅ CachyOS performance optimizations

**Packages installed via Nix on Linux:**
- Nix-specific only: claude-code, nix-index, fastfetch

**Packages installed via pacman on Linux:**
- Core utilities: git, curl, vim, unzip, zip, xz
- Development tools: gh, btop, fzf
- Fonts: ttf-firacode-nerd, ttf-jetbrains-mono-nerd, ttf-meslo-nerd
- Terminals: ghostty (from CachyOS repos - fixes OpenGL issues)
- GUI apps: visual-studio-code-bin (AUR)
- Zsh plugins: zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search
- Gaming: wine, steam, protontricks (optional, via `enableGaming`)

## Platform-Specific Features

### Linux Optimizations
1. **Performance**: `max-jobs = auto` in nix.conf (uses all CPU cores)
2. **Locale fix**: `LOCALE_ARCHIVE` environment variable (prevents warnings)
3. **Desktop integration**: `XDG_DATA_DIRS` for Nix-installed GUI apps
4. **System paths**: Uses `/usr/share/fzf` and system zsh plugins
5. **Ghostty fix**: Uses CachyOS version (no OpenGL issues)

### macOS Configuration
1. **Nix paths**: Uses `${pkgs.fzf}/share/fzf` from Nix
2. **Zsh plugins**: Sources from Nix package paths
3. **Terminal**: `TERMINAL=ghostty` environment variable
4. **Build optimization**: Uses `sysctl -n hw.ncpu` for make/ninja

## How It Works

The configuration uses Nix's conditional logic to detect the platform:

```nix
isLinux = pkgs.stdenv.isLinux;
isDarwin = pkgs.stdenv.isDarwin;

# Install all packages on macOS
] ++ lib.optionals isDarwin [
  git
  curl
  vim
  # ... all packages

# Install minimal packages on Linux
] ++ lib.optionals isLinux [
  # Empty - use pacman instead
```

## Switching Between Platforms

### On macOS
```bash
# Intel Mac
home-manager switch --flake ~/.config/nix#darwin

# Apple Silicon Mac
home-manager switch --flake ~/.config/nix#darwin-arm

# Or use the default (auto-detects)
home-manager switch --flake ~/.config/nix#default
```

### On Linux
```bash
# x86_64 Linux
home-manager switch --flake ~/.config/nix#linux

# ARM64 Linux
home-manager switch --flake ~/.config/nix#linux-arm

# Or use the default
home-manager switch --flake ~/.config/nix#default
```

## Installing on a New System

### macOS
1. Install Nix
2. Clone this repo to `~/.config/nix`
3. Run: `home-manager switch --flake ~/.config/nix#darwin-arm`
4. Done! All packages installed via Nix

### Linux (Arch/CachyOS)
1. Install Nix via pacman: `sudo pacman -S nix`
2. Enable daemon: `sudo systemctl enable --now nix-daemon.service`
3. Clone this repo to `~/.config/nix`
4. **Install system packages first**: `~/.config/nix/scripts/install-arch-packages.sh`
5. Run: `home-manager switch --flake ~/.config/nix#linux`
6. Done! Hybrid setup complete

## Benefits of This Approach

### macOS
- **Simplicity**: Everything managed by Nix
- **Reproducibility**: Exact package versions across machines
- **No system conflicts**: macOS doesn't have pacman

### Linux (Arch)
- **Best of both worlds**: Nix tools + Arch packages
- **Performance**: Native Arch packages with CachyOS optimizations
- **No conflicts**: Separate package namespaces
- **Community support**: Can use Arch Wiki and AUR

## Troubleshooting

### macOS: Packages not found
- Make sure you're using the correct flake: `#darwin` or `#darwin-arm`
- Rebuild: `home-manager switch --flake ~/.config/nix#darwin-arm`

### Linux: Command not found
- Did you run the install script? `~/.config/nix/scripts/install-arch-packages.sh`
- Are pacman packages installed? `pacman -Qi git gh fzf btop`
- Reload shell: `source ~/.zshrc`

### Both: Config not applying
- Check syntax: `nix flake check ~/.config/nix`
- View errors: `home-manager switch --flake ~/.config/nix#default --show-trace`

## References

- [Arch Wiki: Nix](https://wiki.archlinux.org/title/Nix)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
