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
