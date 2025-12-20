#!/usr/bin/env bash
# Install packages via pacman that are also in Nix config
# This prevents conflicts between Nix and Arch package management

set -e

echo "🔧 Installing packages via pacman..."

# Core utilities (likely already installed, but ensuring)
CORE_PACKAGES=(
    git
    curl
    vim
    unzip
    zip
    xz
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
    ghostty  # Terminal with GPU acceleration (fixes OpenGL issues from Nix)
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
    echo "   - ghostty (if not already available)"
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
echo "1. Remove these packages from ~/.config/nix/home.nix"
echo "2. Run: home-manager switch --flake ~/.config/nix#default"
