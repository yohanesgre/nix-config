# Nix Home Manager Configuration
# This file contains user-specific settings for your Nix configuration
{
  # ============================================================================
  # User Configuration
  # ============================================================================

  # Your username (required for flake-based home-manager)
  username = "example";

  # ============================================================================
  # Package Management (Linux only)
  # ============================================================================

  # Set to true to install GUI apps via Nix instead of pacman/AUR
  # Useful if you want Nix-managed versions for reproducibility
  useNixForGuiApps = false;  # false = use pacman/AUR (recommended for Arch)

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
  enableGaming = true;
}
