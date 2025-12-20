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
