# Arch Linux Package Management

This document lists packages that should be installed via pacman instead of Nix to avoid conflicts.

**Note:** This only applies to Linux (Arch/CachyOS). On macOS, all packages are installed via Nix since pacman is not available.

## Core Utilities (pacman)

Already installed on most Arch systems:
```bash
sudo pacman -S git curl vim unzip zip xz
```

## Development Tools (pacman)

```bash
sudo pacman -S github-cli btop fzf
```

## Zsh Plugins (pacman)

```bash
sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
```

## Gaming (pacman) - Optional

```bash
sudo pacman -S wine winetricks steam protontricks
```

## Fonts (pacman)

Nerd fonts are available in Arch repos:
```bash
sudo pacman -S ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-meslo-nerd
```

## AUR Packages

Requires an AUR helper like `yay` or `paru`:
```bash
# VSCode
yay -S visual-studio-code-bin

# Ghostty (if not in repos)
yay -S ghostty
```

## Nix-Only Packages

Keep these in Nix as they're not available/recommended via pacman:
- `claude-code` - Official Claude Code CLI (Nix only)
- `nix-index` - Nix-specific tool

## Quick Install

Run the installation script:
```bash
~/.config/nix/scripts/install-arch-packages.sh
```

## After Installing via Pacman

1. Edit `~/.config/nix/home.nix`
2. Remove the packages you installed via pacman from the `home.packages` list
3. Apply the changes:
   ```bash
   home-manager switch --flake ~/.config/nix#default
   ```

## Package Sync Strategy

- **System packages** (git, curl, etc.) → pacman
- **Zsh plugins** → pacman (better integration with Arch)
- **Gaming** → pacman (CachyOS optimizations)
- **User apps** → Choose based on preference:
  - pacman: System integration, Arch optimizations
  - Nix: Version pinning, cross-system consistency
- **Nix-specific tools** → Nix only
- **Development tools** → Your choice (I recommend pacman for Arch-native)
