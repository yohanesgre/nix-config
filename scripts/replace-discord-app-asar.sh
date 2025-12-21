#!/usr/bin/env bash
# Replace Discord's app.asar with OpenAsar and install theme
# This script automatically replaces Discord's app.asar after Discord installation

set -e

# Configuration
CUSTOM_ASAR="${HOME}/.config/nix/discord-assets/app.asar"
THEME_CSS="${HOME}/.config/nix/discord-assets/system24.theme.css"
BACKUP_SUFFIX=".backup"

# Common Discord installation paths
DISCORD_PATHS=(
    "/opt/discord/resources/app.asar"
    "/usr/lib/discord/resources/app.asar"
    "/usr/lib64/discord/resources/app.asar"
    "/usr/share/discord/resources/app.asar"
    "/var/lib/flatpak/app/com.discordapp.Discord/current/active/files/discord/resources/app.asar"
    "${HOME}/.local/share/flatpak/app/com.discordapp.Discord/current/active/files/discord/resources/app.asar"
)

# Function to find Discord installation
find_discord() {
    for path in "${DISCORD_PATHS[@]}"; do
        if [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

# Function to replace app.asar
replace_asar() {
    local discord_path="$1"
    local backup_path="${discord_path}${BACKUP_SUFFIX}"

    echo "📦 Discord found at: $discord_path"

    # Check if custom app.asar exists
    if [ ! -f "$CUSTOM_ASAR" ]; then
        echo "⚠️  Custom app.asar not found at: $CUSTOM_ASAR"
        echo "   Please place your OpenAsar app.asar in ~/.config/nix/discord-assets/"
        return 1
    fi

    # Show file sizes
    echo "   Original size: $(du -h "$discord_path" | cut -f1)"
    echo "   Custom size:   $(du -h "$CUSTOM_ASAR" | cut -f1)"

    # Create backup if it doesn't exist
    if [ ! -f "$backup_path" ]; then
        echo "💾 Creating backup..."
        sudo cp "$discord_path" "$backup_path"
        echo "   Backup created: $backup_path"
    else
        echo "ℹ️  Backup already exists: $backup_path"
    fi

    # Replace the file
    echo "🔄 Replacing app.asar..."
    sudo cp "$CUSTOM_ASAR" "$discord_path"

    # Verify replacement
    if [ -f "$discord_path" ]; then
        echo "✅ Discord app.asar replaced successfully!"
        echo "   New size: $(du -h "$discord_path" | cut -f1)"

        # Install theme CSS
        local discord_dir=$(dirname "$(dirname "$discord_path")")
        local theme_dest="${HOME}/.config/BetterDiscord/themes/system24.theme.css"

        if [ -f "$THEME_CSS" ]; then
            echo ""
            echo "🎨 Installing system24 theme..."
            mkdir -p "${HOME}/.config/BetterDiscord/themes"
            cp "$THEME_CSS" "$theme_dest"
            echo "✅ Theme installed to: $theme_dest"
            echo "   Enable it in Discord Settings > Themes"
        fi

        echo ""
        echo "ℹ️  Restart Discord to apply changes"
        return 0
    else
        echo "❌ Replacement failed!"
        return 1
    fi
}

# Main script
echo "🔍 Searching for Discord installation..."

if DISCORD_PATH=$(find_discord); then
    replace_asar "$DISCORD_PATH"
else
    echo "⚠️  Discord not found in standard installation paths"
    echo ""
    echo "Checked paths:"
    for path in "${DISCORD_PATHS[@]}"; do
        echo "  - $path"
    done
    echo ""
    echo "If Discord is installed via Flatpak, this script won't work."
    echo "Please modify Discord manually or install via pacman/AUR."
    exit 1
fi
