#!/usr/bin/env bash
# Setup nwg-look symlinks for Nix/Arch compatibility
# This fixes the "Couldn't load the basic lang file" error

set -e

echo "🎨 Setting up nwg-look compatibility..."

# Create symlink for language files in user's home directory
LANGS_DIR="$HOME/.local/share/nwg-look"
mkdir -p "$LANGS_DIR"

if [ ! -L "$LANGS_DIR/langs" ]; then
    echo "   Creating symlink: $LANGS_DIR/langs → /usr/share/nwg-look/langs"
    ln -sf /usr/share/nwg-look/langs "$LANGS_DIR/langs"
fi

if [ ! -L "$LANGS_DIR/main.glade" ]; then
    echo "   Creating symlink: $LANGS_DIR/main.glade → /usr/share/nwg-look/main.glade"
    ln -sf /usr/share/nwg-look/main.glade "$LANGS_DIR/main.glade"
fi

# Create symlink in Nix profiles directory (requires sudo)
NIX_SHARE_DIR="/nix/var/nix/profiles/default/share"
if [ ! -L "$NIX_SHARE_DIR/nwg-look" ] && [ ! -d "$NIX_SHARE_DIR/nwg-look" ]; then
    echo "   Creating Nix profile symlink (requires sudo)..."
    sudo mkdir -p "$NIX_SHARE_DIR"
    sudo ln -sf /usr/share/nwg-look "$NIX_SHARE_DIR/nwg-look"
fi

echo "✅ nwg-look setup complete!"

# Test if nwg-look works
if command -v nwg-look &> /dev/null; then
    echo "   Testing nwg-look..."
    if nwg-look -v &> /dev/null; then
        echo "✅ nwg-look is working correctly"
    else
        echo "⚠️  nwg-look test failed"
    fi
else
    echo "ℹ️  nwg-look is not installed yet"
    echo "   It will be installed via install-arch-packages.sh"
fi
