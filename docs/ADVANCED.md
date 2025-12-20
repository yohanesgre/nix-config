# Flutter Development Environment Setup

This guide explains how to enable and configure Flutter development in your Nix Home Manager configuration.

## Quick Start

### 1. Enable Flutter

Edit `~/.config/nix/config.env` and set:

```toml
enableFlutter = true
```

Optionally, customize the Android SDK command-line tools URL:

```toml
# Update to latest version from:
# https://developer.android.com/studio#command-line-tools-only
androidCmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
```

### 2. Apply Configuration

```bash
home-manager switch --flake ~/.config/nix#yohanes
```

This will install:
- Flutter SDK
- Android Studio
- OpenJDK 17
- Setup script for Android SDK

### 3. Setup Android SDK

After the Nix configuration is applied, run the setup script:

```bash
setup-android-sdk
```

This script will:
- Download and install Android command-line tools
- Accept SDK licenses
- Install essential Android SDK packages (Platform 34, Build Tools, Emulator)
- Create a Pixel 6 Android Virtual Device (AVD)

### 4. Verify Installation

```bash
flutter doctor
```

## What Gets Installed

### Packages
- **Flutter**: Latest stable Flutter SDK from nixpkgs
- **Android Studio**: Full IDE for Android development
- **JDK 17**: Required for Android development

### Environment Variables
- `JAVA_HOME`: Points to OpenJDK 17
- `ANDROID_HOME`: `~/Developments/Sdk/android-sdk`
- `ANDROID_SDK_ROOT`: `~/Developments/Sdk/android-sdk`

### PATH Additions
- `$ANDROID_HOME/cmdline-tools/latest/bin`
- `$ANDROID_HOME/platform-tools`
- `$ANDROID_HOME/build-tools/34.0.0`

### Scripts
- `setup-android-sdk`: Located at `~/.local/bin/setup-android-sdk`

## Android SDK Structure

After running `setup-android-sdk`, your Android SDK will be located at:

```
~/Developments/Sdk/android-sdk/
├── cmdline-tools/
│   └── latest/
├── platform-tools/
├── platforms/
│   └── android-34/
├── build-tools/
│   └── 34.0.0/
├── emulator/
└── system-images/
    └── android-34/
```

## Common Commands

### Flutter
```bash
flutter doctor          # Check Flutter environment
flutter doctor -v       # Verbose environment check
flutter devices         # List connected devices
flutter emulators       # List available emulators
flutter create myapp    # Create new Flutter project
```

### Android SDK Manager
```bash
sdkmanager --list                           # List available packages
sdkmanager --install "platforms;android-35" # Install Android 35
sdkmanager --update                         # Update installed packages
```

### Android Emulator
```bash
emulator -list-avds                    # List available AVDs
emulator -avd pixel_6_api_34          # Start Pixel 6 emulator
avdmanager list                        # List all AVD information
avdmanager create avd -n mydevice ...  # Create custom AVD
```

## Troubleshooting

### Flutter doctor shows issues

Run with verbose flag to see details:
```bash
flutter doctor -v
```

### Android licenses not accepted

Re-run license acceptance:
```bash
yes | sdkmanager --licenses
```

### Emulator won't start

Check available AVDs:
```bash
emulator -list-avds
```

Create a new AVD if needed:
```bash
avdmanager create avd -n pixel_6_api_34 -k "system-images;android-34;google_apis;x86_64" -d "pixel_6"
```

### ANDROID_HOME not set

Make sure you've reloaded your shell:
```bash
source ~/.zshrc
```

Or restart your terminal.

### Flutter not in PATH

Verify Flutter is installed:
```bash
which flutter
```

If not found, rebuild your Home Manager configuration:
```bash
home-manager switch --flake ~/.config/nix#yohanes
```

## Updating Android SDK Tools

To update to the latest Android command-line tools:

1. Get the latest URL from [Android Studio downloads](https://developer.android.com/studio#command-line-tools-only)

2. Update `config.env`:
   ```toml
   androidCmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-linux-XXXXXXX_latest.zip"
   ```

3. Remove existing tools and re-run setup:
   ```bash
   rm -rf ~/Developments/Sdk/android-sdk/cmdline-tools
   setup-android-sdk
   ```

## Disabling Flutter

To disable Flutter and remove the packages:

1. Edit `~/.config/nix/config.env` and set:
   ```toml
   enableFlutter = false
   ```

2. Apply configuration:
   ```bash
   home-manager switch --flake ~/.config/nix#yohanes
   ```

3. Optionally remove Android SDK directory:
   ```bash
   rm -rf ~/Developments/Sdk/android-sdk
   ```

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Android SDK Command-line Tools](https://developer.android.com/tools)
- [Nix Home Manager](https://nix-community.github.io/home-manager/)
# Managing Sensitive Data in Nix Configuration

Since `config.nix` is tracked in git, **never** put sensitive information directly in it.

## What counts as sensitive?
- API keys and tokens
- Passwords
- Email addresses (if privacy is a concern)
- SSH keys
- Personal identifiers
- Any credentials

## Recommended Approaches

### 1. Environment Variables
Use environment variables for runtime secrets:

```nix
# In config.nix
{
  programs.git = {
    userEmail = builtins.getEnv "GIT_EMAIL";
  };
}
```

Set the variable in your shell profile:
```bash
export GIT_EMAIL="your-email@example.com"
```

### 2. Separate Untracked File
Create a `secrets.nix` file that's gitignored:

```nix
# secrets.nix (add to .gitignore)
{
  email = "your-email@example.com";
  apiKey = "your-api-key";
}
```

Import it in `config.nix`:
```nix
# config.nix
let
  secrets = import ./secrets.nix;
in
{
  programs.git = {
    userEmail = secrets.email;
  };
}
```

Add to `.gitignore`:
```
secrets.nix
```

Create `secrets.nix.example` as a template:
```nix
# secrets.nix.example
{
  email = "user@example.com";
  apiKey = "your-api-key-here";
}
```

### 3. sops-nix (Recommended for Advanced Users)
Encrypts secrets in git using age or PGP keys.

Install:
```nix
# In your flake.nix inputs
sops-nix.url = "github:Mic92/sops-nix";
```

Usage:
```nix
# Create encrypted secrets file
sops secrets.yaml

# Reference in config
sops.secrets.example-key = {};
```

See: https://github.com/Mic92/sops-nix

### 4. agenix
Similar to sops-nix, uses age encryption.

See: https://github.com/ryantm/agenix

## Quick Reference

| Method | Complexity | Best For |
|--------|------------|----------|
| Environment Variables | Low | Runtime configs, simple secrets |
| Untracked File | Low | Personal configs, development |
| sops-nix | Medium | Team environments, multiple machines |
| agenix | Medium | NixOS systems, declarative secrets |

## For This Repository

This repo uses the **separate untracked file** approach:
- Create `secrets.nix` with your sensitive data
- Import it in `config.nix` where needed
- Never commit `secrets.nix` to git
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
