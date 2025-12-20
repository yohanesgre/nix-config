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
)

# Development tools
DEV_PACKAGES=(
    github-cli  # gh
    btop
    fzf
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
    xdg-desktop-portal-hyprland
    swww                    # Wallpaper daemon with smooth transitions
    wofi                    # Application launcher
    wlogout                 # Logout menu
    dunst                   # Notification daemon
    grim                    # Screenshot tool
    slurp                   # Screen area selection
    wl-clipboard            # Wayland clipboard utilities
    cliphist                # Clipboard history manager
    brightnessctl           # Brightness control
    playerctl               # Media player control
    pamixer                 # PulseAudio mixer
    polkit-kde-agent        # Polkit authentication agent
    qt5-wayland             # Qt5 Wayland support
    qt6-wayland             # Qt6 Wayland support
    dolphin                 # File manager (from your config)
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
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
    ttf-meslo-nerd
)

# AUR packages (requires yay or paru)
AUR_PACKAGES=(
    visual-studio-code-bin
    ghostty                 # Terminal with GPU acceleration
    matugen                 # Color theme generator for wallpapers
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
    echo "📦 AUR packages (requires yay or paru):"
    echo "   - visual-studio-code-bin"
    echo "   - ghostty"
    echo "   - matugen (for wallpaper color themes)"
    echo ""
    read -p "Install AUR packages with yay? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v yay &> /dev/null; then
            yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
        elif command -v paru &> /dev/null; then
            paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"
        else
            echo "⚠️  yay or paru not found. Please install AUR packages manually:"
            for pkg in "${AUR_PACKAGES[@]}"; do
                echo "   - $pkg"
            done
        fi
    fi
fi

echo ""
echo "✅ Package installation complete!"
echo ""
echo "Next steps:"
echo "1. Reload Hyprland or logout/login to apply changes"
echo "2. Test wallpaper switching with Super + Shift + W"
echo "3. Your wallpaper will auto-load on next Hyprland startup"
