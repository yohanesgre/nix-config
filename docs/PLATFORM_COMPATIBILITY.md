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
