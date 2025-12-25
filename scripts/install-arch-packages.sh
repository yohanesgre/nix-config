#!/usr/bin/env bash
# Install packages via pacman that cannot be managed by Nix
# CLI tools, fonts, and development utilities are now in home.nix

set -e

# Ensure we have access to system binaries
export PATH="/usr/bin:/usr/sbin:$PATH"

echo "🔧 Installing system packages via pacman..."

# System-critical packages
SYSTEM_PACKAGES=(
    flatpak      # System flatpak (required for system integration)
    base-devel   # Required for building AUR packages
)

# Hyprland and Wayland ecosystem (GUI apps and system services)
WAYLAND_PACKAGES=(
    hyprland                      # Window manager
    waybar                        # Status bar for Wayland
    swww                          # Wallpaper daemon with smooth transitions
    rofi-wayland                  # Application launcher (Wayland fork)
    wlogout                       # Logout menu
    swaync                        # Sway Notification Center
    swappy                        # Screenshot annotation tool
    brightnessctl                 # Brightness control (hardware access)
    pamixer                       # PulseAudio mixer (system audio)
    polkit-gnome                  # Polkit authentication agent (GTK-based)
    qt5-wayland                   # Qt5 Wayland support (for compatibility)
    qt6-wayland                   # Qt6 Wayland support (for compatibility)
    nautilus                      # File manager GUI
    gvfs                          # Virtual filesystem (trash, network shares)
    gvfs-mtp                      # MTP device support (Android phones)
    gvfs-gphoto2                  # Camera support
    file-roller                   # Archive manager (for Nautilus integration)
    hypridle                      # Idle management daemon for Hyprland
    hyprlock                      # Screen locker for Hyprland
    gsettings-desktop-schemas     # GSettings schemas (required for swaync and Nautilus)
)

# Gaming (optional)
GAMING_PACKAGES=(
    wine
    winetricks
    steam
    protontricks
)

# AUR packages (requires yay or paru)
AUR_PACKAGES=(
    visual-studio-code-bin
    ghostty                 # Terminal with GPU acceleration
    matugen                 # Color theme generator for wallpapers
    alacritty
    vicinae-bin
    dracula-gtk-theme
    dracula-icons-git
    nwg-look                # GTK theme selector and customization tool
    discord                 # Discord client (required for app.asar replacement)
    hyprsession
)

echo ""
echo "📦 Installing system packages..."
sudo pacman -S --needed --noconfirm "${SYSTEM_PACKAGES[@]}"

echo ""
echo "📦 Installing Wayland ecosystem (compatible with both Hyprland and KDE Plasma)..."
sudo pacman -S --needed --noconfirm "${WAYLAND_PACKAGES[@]}"

# Function to install yay
install_yay() {
    if command -v yay &> /dev/null; then
        echo "✅ yay is already installed"
        return 0
    fi
    
    echo "📦 Installing yay (AUR helper)..."
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone and build yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    
    # Cleanup
    cd ~
    rm -rf "$TEMP_DIR"
    
    echo "✅ yay installed successfully"
}

# Check if running in auto mode (from home-manager activation)
AUTO_MODE="${AUTO_MODE:-false}"

if [ "$AUTO_MODE" = "true" ]; then
    # Auto mode: Skip gaming and AUR (can install manually later)
    echo "ℹ️  Auto-mode: Skipping gaming and AUR packages"
    echo "   Run manually with 'install-arch-packages.sh' to install gaming/AUR packages"
else
    # Interactive mode: Ask user
    echo ""
    read -p "Install gaming packages (wine, steam, etc.)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Installing gaming packages..."
        sudo pacman -S --needed --noconfirm "${GAMING_PACKAGES[@]}"
    fi

    echo ""
    echo "📦 AUR packages available:"
    echo "   - visual-studio-code-bin"
    echo "   - ghostty"
    echo "   - matugen (for wallpaper color themes)"
    echo "   - alacritty"
    echo "   - vicinae-bin"
    echo "   - hyprsession"
    echo "   - dracula themes"
    echo ""
    read -p "Install AUR packages? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Install yay first if needed
        install_yay
        
        if command -v yay &> /dev/null; then
            echo "📦 Installing AUR packages..."
            yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
        elif command -v paru &> /dev/null; then
            echo "📦 Using paru to install AUR packages..."
            paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"
        else
            echo "⚠️  Could not install yay. Please install AUR packages manually:"
            for pkg in "${AUR_PACKAGES[@]}"; do
                echo "   - $pkg"
            done
        fi
    fi
fi

echo ""
echo "📦 Installing Flatpak applications..."
flatpak install -y flathub io.github.zen_browser.zen

echo ""
echo "🎮 Setting up Discord with OpenAsar and theme..."
if [ -f "$HOME/.local/bin/replace-discord-app-asar" ]; then
    # Only run if custom app.asar exists
    if [ -f "$HOME/.config/nix/discord-assets/app.asar" ]; then
        $HOME/.local/bin/replace-discord-app-asar || echo "⚠️  Discord setup failed"
    else
        echo "ℹ️  OpenAsar not found in ~/.config/nix/discord-assets/, skipping Discord customization"
        echo "   To customize Discord later, place your files in ~/.config/nix/discord-assets/ and run:"
        echo "   replace-discord-app-asar"
    fi
else
    echo "⚠️  replace-discord-app-asar script not found"
fi

echo ""
echo "✅ Package installation complete!"
echo ""
echo "ℹ️  Note: CLI tools, fonts, and development utilities are managed by Nix (see home.nix)"
echo ""
echo "Next steps:"
echo "1. Run 'home-manager switch --flake ~/.config/nix#archlinux' to install Nix packages"
echo "2. Logout/login to apply changes (works with both Hyprland and KDE Plasma)"
echo "3. If using Hyprland: Test wallpaper switching with Super + Shift + W"
echo "4. If you installed Discord, restart it to apply app.asar changes"
