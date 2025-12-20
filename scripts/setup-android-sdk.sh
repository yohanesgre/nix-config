#!/bin/bash

# Android SDK Setup Script for Nix
# This script sets up the Android SDK for Flutter development

set -e  # Exit on error

# Ensure we have access to system binaries
export PATH="/usr/bin:/usr/sbin:$PATH"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

echo ""
log_info "🚀 Setting up Android SDK for Flutter development..."
echo ""

# Check if ANDROID_HOME is set
if [[ -z "$ANDROID_HOME" ]]; then
    log_error "ANDROID_HOME is not set. Please enable Flutter in your Nix configuration first."
    log_info "Set enableFlutter = true in ~/.config/nix/home.nix"
    exit 1
fi

# Create SDK directories
ANDROID_SDK_DIR="$HOME/Developments/Sdk/android-sdk"
FLUTTER_SDK_DIR="$HOME/Developments/Sdk/flutter"
log_info "Creating SDK directories..."
mkdir -p "$ANDROID_SDK_DIR"
mkdir -p "$HOME/Developments/Sdk"

# Download and install Android command-line tools
if [[ ! -d "$ANDROID_SDK_DIR/cmdline-tools/latest" ]]; then
    log_info "Downloading Android command-line tools..."

    # Use environment variable or fall back to default
    CMDLINE_TOOLS_URL="${ANDROID_CMDLINE_TOOLS_URL:-https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip}"
    TEMP_DIR=$(mktemp -d)

    cd "$TEMP_DIR"
    curl -o commandlinetools.zip "$CMDLINE_TOOLS_URL"

    log_info "Extracting command-line tools..."
    unzip -q commandlinetools.zip

    # Create proper directory structure
    mkdir -p "$ANDROID_SDK_DIR/cmdline-tools"
    mv cmdline-tools "$ANDROID_SDK_DIR/cmdline-tools/latest"

    # Clean up
    rm commandlinetools.zip
    cd -
    rm -rf "$TEMP_DIR"

    log_success "Android command-line tools installed"
else
    log_success "Android command-line tools already installed"
fi

# Set up environment for sdkmanager
export PATH="$ANDROID_SDK_DIR/cmdline-tools/latest/bin:$PATH"

# Accept licenses
log_info "Accepting Android SDK licenses..."
yes | sdkmanager --licenses > /dev/null 2>&1 || log_warning "Some licenses may require manual acceptance"

# Install essential SDK packages
log_info "Installing Android SDK packages..."
log_info "This may take a few minutes..."

sdkmanager --install \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "emulator" \
    "system-images;android-34;google_apis;x86_64" || log_warning "Some packages may have failed to install"

log_success "Android SDK packages installed"

# Download and install Flutter SDK
if [[ ! -d "$FLUTTER_SDK_DIR/bin" ]]; then
    log_info "Downloading Flutter SDK..."

    # Use environment variable or fall back to default
    FLUTTER_URL="${FLUTTER_SDK_URL:-https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz}"
    TEMP_DIR=$(mktemp -d)

    cd "$TEMP_DIR"
    curl -o flutter.tar.xz "$FLUTTER_URL"

    log_info "Extracting Flutter SDK..."
    tar -xf flutter.tar.xz -C "$HOME/Developments/Sdk/"

    # Clean up
    rm flutter.tar.xz
    cd -
    rm -rf "$TEMP_DIR"

    log_success "Flutter SDK installed"
else
    log_success "Flutter SDK already installed"
fi

# Set up Flutter path for this script
export PATH="$FLUTTER_SDK_DIR/bin:$PATH"

# Create and configure AVD (Android Virtual Device)
log_info "Creating Android Virtual Device (AVD)..."
echo "no" | avdmanager create avd \
    -n "pixel_6_api_34" \
    -k "system-images;android-34;google_apis;x86_64" \
    -d "pixel_6" || log_warning "AVD may already exist or failed to create"

log_success "AVD created: pixel_6_api_34"

# Verify installation
echo ""
log_info "Verifying Flutter and Android SDK setup..."
echo ""

if command -v flutter &> /dev/null; then
    flutter doctor
else
    log_error "Flutter not found in PATH. Please ensure Flutter is installed via Nix."
fi

echo ""
log_success "🎉 Android SDK setup completed!"
echo ""
log_info "📋 Next steps:"
echo "   1. Restart your terminal or run: source ~/.zshrc"
echo "   2. Run: flutter doctor -v (to verify complete setup)"
echo "   3. Run: flutter devices (to see available devices)"
echo "   4. To start emulator: emulator -avd pixel_6_api_34"
echo ""
log_info "📝 Useful commands:"
echo "   • flutter doctor         - Check Flutter environment"
echo "   • flutter devices        - List connected devices"
echo "   • flutter emulators      - List available emulators"
echo "   • sdkmanager --list      - List available SDK packages"
echo ""
