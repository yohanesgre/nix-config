# VSCode Installation Options on Arch Linux

You have two options for installing VSCode on Arch Linux with this Nix configuration.

## Option 1: VSCode via pacman/AUR (Recommended)

**Status:** ✅ Currently configured (default)

**Configuration:**
```nix
# In config.nix
useNixForGuiApps = false;  # Default
```

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

**Configuration:**
```nix
# In config.nix
useNixForGuiApps = true;
```

**Installation:**
```bash
home-manager switch --flake ~/.config/nix#default
```

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

2. **Enable in config.nix**:
   ```nix
   useNixForGuiApps = true;
   ```

3. **Apply changes**:
   ```bash
   home-manager switch --flake ~/.config/nix#default
   ```

4. **Verify**:
   ```bash
   which code
   # Should show: /home/yohanes/.nix-profile/bin/code
   ```

### Switch back to AUR version

1. **Disable in config.nix**:
   ```nix
   useNixForGuiApps = false;
   ```

2. **Apply changes**:
   ```bash
   home-manager switch --flake ~/.config/nix#default
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
