# Auto-Run Scripts

Home Manager automatically runs certain scripts during activation.

## Auto-Run Scripts

### 1. **SSH Key Setup** (First Time Only)

**Script:** `setup-ssh-key.sh`
**When:** First activation (when `~/.ssh/id_ed25519` doesn't exist)
**Frequency:** Once

```bash
# Checks if SSH key exists
if [ ! -f ~/.ssh/id_ed25519 ]; then
  # Runs setup-ssh-key interactively
fi
```

**Skip:** If you already have an SSH key, this is automatically skipped.

### 2. **ROYUAN Keyboard Fix** (Linux Only, Every Time)

**Script:** `fix-royuan-keyboard.sh`
**When:** Every activation on Linux
**Frequency:** Every `home-manager switch`

```bash
# Applies keyboard fixes
echo "⌨️  Applying ROYUAN keyboard fixes..."
fix-royuan-keyboard
```

**Disable:** Remove the script from `~/.local/bin/` or comment out the activation hook in `home.nix`.

### 3. **Arch Packages Installation** (First Time Only)

**Script:** `install-arch-packages.sh`
**When:** First activation on Arch Linux
**Frequency:** Once (creates marker file)

```bash
# Auto-mode: Installs core packages only
# Skips gaming and AUR packages (install manually)
AUTO_MODE=true install-arch-packages.sh
```

**Marker file:** `~/.local/share/nix-home-manager/arch-packages-installed`

**Re-run:** Delete the marker file or run the script manually:
```bash
# Run interactively with gaming/AUR prompts
install-arch-packages.sh

# Or remove marker to trigger auto-run again
rm ~/.local/share/nix-home-manager/arch-packages-installed
hm
```

### 4. **Android SDK Setup** (When Flutter Enabled)

**Script:** `setup-android-sdk.sh`
**When:** Every activation when `enableFlutter = true`
**Frequency:** Every time (idempotent)

```bash
# Only runs when enableFlutter = true in config.nix
```

## Script Behavior

### Auto Mode vs Interactive Mode

**Auto Mode** (from home-manager activation):
- Runs non-interactively
- Skips optional prompts
- Minimal installation
- Safe for automated runs

**Interactive Mode** (manual run):
- Prompts for user input
- Offers optional packages
- Full control
- Run anytime: `~/.local/bin/script-name.sh`

## Controlling Auto-Run

### Disable a Script

**Option 1:** Remove from `.local/bin/`
```bash
rm ~/.local/bin/fix-royuan-keyboard
```

**Option 2:** Comment out in `home.nix`
```nix
# Comment out the activation hook:
# autoFixKeyboard = lib.hm.dag.entryAfter ["writeBoundary"] ''
#   ...
# '';
```

### Force Re-Run (One-Time Scripts)

```bash
# SSH key setup - delete existing key (backup first!)
rm ~/.ssh/id_ed25519*
hm

# Arch packages - delete marker file
rm ~/.local/share/nix-home-manager/arch-packages-installed
hm
```

## Viewing Auto-Run Output

Auto-run scripts show output during `home-manager switch`:

```bash
$ hm
...
⌨️  Applying ROYUAN keyboard fixes...
✅ Keyboard configured

📦 First-time setup: Installing Arch packages...
✅ Arch packages installed
...
```

## Troubleshooting

### Script Fails During Activation

**Problem:** Script exits with error code
**Solution:** Run manually to see detailed error:
```bash
~/.local/bin/script-name.sh
```

### Package Installation Needs Sudo

**Problem:** `install-arch-packages.sh` fails (needs sudo)
**Solution:** Run manually:
```bash
install-arch-packages.sh
# Enter sudo password when prompted
```

### Script Runs Every Time (Should Be Once)

**Problem:** Marker file not created
**Solution:** Check marker file location and permissions:
```bash
ls -la ~/.local/share/nix-home-manager/
```

## Adding Custom Auto-Run Scripts

Add to `home.nix`:

```nix
home.activation = lib.mkMerge [
  {
    myCustomScript = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Running my custom script..."
      $DRY_RUN_CMD ${config.home.homeDirectory}/.local/bin/my-script.sh
    '';
  }
]
```

**Tips:**
- Use `$DRY_RUN_CMD` prefix for dry-run support
- Add error handling: `|| echo "⚠️  Failed"`
- Make idempotent (safe to run multiple times)
- Use marker files for one-time scripts

## See Also

- [scripts/](../scripts/) - Available scripts
- [home.nix](../home.nix) - Activation hooks configuration
- [Home Manager Manual](https://nix-community.github.io/home-manager/) - Activation scripts
