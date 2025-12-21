#!/usr/bin/env bash
# Install packages via pacman that are also in Nix config
# This prevents conflicts between Nix and Arch package management

set -e

# Ensure we have access to system binaries
export PATH="/usr/bin:/usr/sbin:$PATH"

echo "🔧 Installing packages via pacman..."

# Core utilities (likely already installed, but ensuring)
CORE_PACKAGES=(
    git
    curl
    vim
    unzip
    zip
    xz
    usbutils  # Provides lsusb for USB device detection
    flatpak   # System flatpak (not Nix flatpak)
    base-devel  # Required for building AUR packages
)

# Development tools
DEV_PACKAGES=(
    github-cli  # gh
    btop
    fzf
    yazi                    # Modern terminal file manager
    ffmpegthumbnailer       # Video thumbnails for yazi
    zoxide                  # Smart directory jumper for yazi
)

# Zsh plugins
ZSH_PACKAGES=(
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
)

# Hyprland and Wayland ecosystem
HYPRLAND_PACKAGES=(
    hyprland
    waybar                  # Status bar for Wayland
    swww                    # Wallpaper daemon with smooth transitions
    rofi-wayland            # Application launcher (Wayland fork)
    wlogout                 # Logout menu
    swaync                  # Sway Notification Center
    swappy                  # Screenshot annotation tool
    grim                    # Screenshot tool
    slurp                   # Screen area selection
    wl-clipboard            # Wayland clipboard utilities
    cliphist                # Clipboard history manager
    brightnessctl           # Brightness control
    pamixer                 # PulseAudio mixer
    polkit-kde-agent        # Polkit authentication agent
    qt5-wayland             # Qt5 Wayland support
    qt6-wayland             # Qt6 Wayland support
    qt6ct                   # Qt6 configuration tool
    kvantum                 # Qt theme engine
    dolphin                 # File manager (from your config)
    swayidle                # Idle management daemon
    swaylock-effects        # Screen locker with effects
    gsettings-desktop-schemas  # GSettings schemas (required for swaync)
)

# Gaming (optional)
GAMING_PACKAGES=(
    wine
    winetricks
    steam
    protontricks
)

# Fonts
FONT_PACKAGES=(
    ttf-fira-code
    ttf-font-awesome
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
    ttf-meslo-nerd
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
)

echo ""
echo "📦 Installing core utilities..."
sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}"

echo ""
echo "📦 Installing development tools..."
sudo pacman -S --needed --noconfirm "${DEV_PACKAGES[@]}"

echo ""
echo "📦 Installing Zsh plugins..."
sudo pacman -S --needed --noconfirm "${ZSH_PACKAGES[@]}"

echo ""
echo "📦 Installing Hyprland and Wayland ecosystem..."
sudo pacman -S --needed --noconfirm "${HYPRLAND_PACKAGES[@]}"

echo ""
echo "📦 Installing fonts..."
sudo pacman -S --needed --noconfirm "${FONT_PACKAGES[@]}"

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
echo "Next steps:"
echo "1. Reload Hyprland or logout/login to apply changes"
echo "2. Test wallpaper switching with Super + Shift + W"
echo "3. Your wallpaper will auto-load on next Hyprland startup"
echo "4. If you installed Discord, restart it to apply app.asar changes"
