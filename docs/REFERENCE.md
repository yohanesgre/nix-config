# Configuration Architecture

This Nix configuration uses **inline platform-specific profiles** - the recommended pattern for multi-platform Home Manager configurations.

## How It Works

The configuration automatically detects your platform and applies the appropriate profile:

```nix
# Platform detection
isLinux = pkgs.stdenv.isLinux;
isDarwin = pkgs.stdenv.isDarwin;

# Conditional package installation
home.packages = with pkgs; [
  # Common packages (all platforms)
  claude-code
  nix-index
  fastfetch
] ++ lib.optionals isDarwin [
  # macOS-specific packages
  git, curl, vim, vscode, ghostty, ...
] ++ lib.optionals isLinux [
  # Linux-specific packages (minimal on Arch)
];
```

## Platform Profiles

### Arch Linux Profile

**Location:** `home.nix` lines 54-59

**Philosophy:** Hybrid Nix + pacman management
- Nix: claude-code, nix-index, fastfetch
- Pacman: Everything else (git, curl, vim, fonts, GUI apps)

**Environment:**
- `FZF_BASE = "/usr/share/fzf"` (system path)
- `LOCALE_ARCHIVE` (Arch Wiki recommendation)
- `XDG_DATA_DIRS` (desktop integration)

**Aliases:**
- Arch-specific: `update`, `cleanup`, `rmpkg`, `jctl`
- Pacman helpers

**Scripts:**
- `fix-royuan-keyboard` (hardware-specific)

### macOS Profile

**Location:** `home.nix` lines 36-54

**Philosophy:** Full Nix package management
- All packages via Nix (no pacman available)

**Environment:**
- `FZF_BASE = "${pkgs.fzf}/share/fzf"` (Nix path)
- `TERMINAL = "ghostty"`

**Aliases:**
- macOS-specific: `update` (brew), CPU detection via `sysctl`

**Scripts:**
- None (no hardware-specific scripts needed)

## Why Inline Profiles?

### Advantages ✅
1. **Single source of truth** - One file to maintain
2. **No infinite recursion** - Nix doesn't support conditional imports well
3. **Recommended pattern** - Used by Home Manager examples
4. **Easy to understand** - Clear `lib.optionals` blocks
5. **DRY principle** - Common config defined once

### Why Not Separate Files? ❌
1. Conditional imports cause infinite recursion in Nix
2. More complex to maintain
3. Harder to see the full picture
4. Not the idiomatic Nix way

## Configuration Hierarchy

```
config.nix                    # User settings (enableFlutter, enableGaming, etc.)
    ↓
home.nix                      # Main configuration
    ├── Common packages       # All platforms
    ├── macOS profile         # lib.optionals isDarwin [...]
    ├── Linux profile         # lib.optionals isLinux [...]
    ├── Flutter packages      # lib.optionals enableFlutter [...]
    └── Gaming packages       # lib.optionals (isLinux && enableGaming) [...]
    ↓
nix.conf                      # Arch-optimized Nix settings
```

## Customization Per Platform

### Adding Arch-only Packages
```nix
] ++ lib.optionals isLinux [
  # Add your package here
  my-arch-package
]
```

### Adding macOS-only Packages
```nix
] ++ lib.optionals isDarwin [
  # Add your package here
  my-macos-package
]
```

### Platform-specific Environment Variables
```nix
} // lib.optionalAttrs isDarwin {
  MY_VAR = "macOS value";
} // lib.optionalAttrs isLinux {
  MY_VAR = "Linux value";
}
```

### Platform-specific Aliases
```nix
} // lib.optionalAttrs isLinux {
  my-alias = "linux-command";
} // lib.optionalAttrs isDarwin {
  my-alias = "macos-command";
}
```

## Package Count by Platform

### Arch Linux
- **Nix packages:** 3 (claude-code, nix-index, fastfetch)
- **Pacman packages:** ~15+ (git, curl, vim, fonts, etc.)
- **Total:** Hybrid management

### macOS
- **Nix packages:** ~20 (everything)
- **Homebrew:** 0 (optional, user choice)
- **Total:** Full Nix management

## Best Practices

1. ✅ **Keep common config at the top** - Shared by all platforms
2. ✅ **Use `lib.optionals`** - Platform-specific packages
3. ✅ **Use `lib.optionalAttrs`** - Platform-specific environment vars
4. ✅ **Comment your sections** - Explain why each block exists
5. ✅ **Test on both platforms** - Ensure no breakage

## Further Reading

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Language Basics](https://nixos.org/manual/nix/stable/language/)
- [PLATFORM_COMPATIBILITY.md](./PLATFORM_COMPATIBILITY.md) - Usage guide
- [PACMAN_PACKAGES.md](./PACMAN_PACKAGES.md) - Arch package strategy
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
- `fastfetch` - Cross-platform system info tool

## Optional: GUI Apps via Nix

You can optionally install VSCode and Ghostty via Nix instead of pacman/AUR by setting `useNixForGuiApps = true` in `config.nix`.

**Pros of using Nix for GUI apps:**
- ✅ Version pinning and reproducibility
- ✅ Easy rollback
- ✅ Consistent across Linux and macOS

**Cons of using Nix for GUI apps:**
- ❌ May have desktop integration issues
- ❌ Ghostty has OpenGL issues on some systems (pacman version works better)
- ❌ Larger Nix store size

**Recommendation:** Use pacman/AUR for GUI apps on Arch Linux for better system integration.

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
# VSCode Installation Options on Arch Linux

You have two options for installing VSCode on Arch Linux.

## Option 1: VSCode via pacman/AUR (Recommended)

**Status:** ✅ Default configuration

**How it works:**
- The `#archlinux` profile doesn't install VSCode via Nix
- Install VSCode manually via pacman/AUR

**Installation:**
```bash
yay -S visual-studio-code-bin
# or
~/.config/nix/scripts/install-arch-packages.sh
```

**Pros:**
- ✅ Better desktop integration (MIME types, .desktop files)
- ✅ Uses system GTK/Qt themes
- ✅ Native Arch package management
- ✅ Smaller Nix store
- ✅ Automatic updates via pacman/AUR
- ✅ Better compatibility with system libraries

**Cons:**
- ❌ Different version on Linux vs macOS
- ❌ Can't easily roll back to previous versions
- ❌ Not reproducible across systems

**Binary location:** `/usr/bin/code`

## Option 2: VSCode via Nix

**How to enable:**

Add VSCode to the macOS package list in `home.nix`, or create a custom profile.

**Pros:**
- ✅ Version pinning and reproducibility
- ✅ Same version on Linux and macOS
- ✅ Easy rollback with `home-manager generations`
- ✅ Declarative configuration
- ✅ No need for AUR helper

**Cons:**
- ❌ May have desktop integration issues
- ❌ Larger Nix store size
- ❌ May conflict with extensions expecting system paths
- ❌ Might not respect system themes perfectly

**Binary location:** `~/.nix-profile/bin/code`

## How to Switch

### Switch to Nix-managed VSCode

1. **Remove AUR version** (if installed):
   ```bash
   yay -R visual-studio-code-bin
   ```

2. **Add VSCode to home.nix**:
   ```nix
   # In home.nix, add to the macOS package list:
   ] ++ lib.optionals isDarwin [
     vscode  # Add this
     # ... other macOS packages
   ]

   # Or add to Linux packages if you want Nix VSCode on Arch:
   ] ++ lib.optionals isLinux [
     vscode  # Add this
   ]
   ```

3. **Apply changes**:
   ```bash
   home-manager switch --flake ~/.config/nix#archlinux
   ```

4. **Verify**:
   ```bash
   which code
   # Should show: /home/yohanes/.nix-profile/bin/code
   ```

### Switch back to AUR version

1. **Remove from home.nix**:
   ```nix
   # Remove vscode from the package list
   ```

2. **Apply changes**:
   ```bash
   home-manager switch --flake ~/.config/nix#archlinux
   ```

3. **Install AUR version**:
   ```bash
   yay -S visual-studio-code-bin
   ```

4. **Verify**:
   ```bash
   which code
   # Should show: /usr/bin/code
   ```

## Recommendation

For **Arch Linux**: Use **pacman/AUR** (Option 1)
- Better system integration
- Follows Arch philosophy
- Works better with CachyOS optimizations

For **cross-platform reproducibility**: Use **Nix** (Option 2)
- Same setup on macOS and Linux
- Version pinning
- Declarative configuration

## VSCode Extensions

Both options support VSCode extensions normally. Extensions are stored in:
- `~/.vscode/extensions` (same for both Nix and AUR)

Extensions work identically regardless of how VSCode is installed.

## Current Status Check

```bash
# Check which VSCode is installed
which code

# If Nix-managed:
nix-env -q | grep vscode

# If pacman-managed:
pacman -Qi visual-studio-code-bin

# Check version
code --version
```

## Troubleshooting

### VSCode not found after switching
- Reload shell: `source ~/.zshrc`
- Check PATH: `echo $PATH`
- Verify installation: `ls -la ~/.nix-profile/bin/code` or `ls -la /usr/bin/code`

### Desktop integration issues (Nix version)
- Update desktop database: `update-desktop-database ~/.local/share/applications`
- Set `XDG_DATA_DIRS` (already configured in home.nix)

### Both versions installed
- Remove one to avoid conflicts
- Check which one runs: `which code`
