# Nix Home Manager Configuration
# This file contains user-specific settings for your Nix configuration
{
  # ============================================================================
  # User Configuration
  # ============================================================================

  # Your username (required for flake-based home-manager)
  username = "example";

  # Git Configuration 
  gitUserName = "";
  gitUserEmail = "";

  # ============================================================================
  # Flutter Development Environment
  # ============================================================================

  # Set to true to install Flutter, Android Studio, and Android SDK tools
  enableFlutter = false;

  # Flutter SDK URL
  # Update this to the latest stable version from:
  # https://docs.flutter.dev/release/archive
  flutterSdkUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz";

  # Android SDK Command-line Tools URL
  # Update this to the latest version from:
  # https://developer.android.com/studio#command-line-tools-only
  androidCmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip";

  # ============================================================================
  # Gaming Environment (Linux only)
  # ============================================================================

  # Set to true to install Steam, Wine, and gaming-related packages
  enableGaming = false;

  # ============================================================================
  # Hardware-Specific Features (Linux only)
  # ============================================================================

  # Set to true to enable ROYUAN OLV75 keyboard fnmode fix
  # This fixes function key behavior for ROYUAN keyboards
  enableRoyuanKeyboard = false; 

  # ============================================================================
  # Auto-Installation Behavior
  # ============================================================================

  # Set to true to force reinstallation of Arch packages on next activation
  # This will ignore the marker file and run install-arch-packages.sh again
  # Note: You need to manually set this back to false after running
  freshInstall = false;
}
