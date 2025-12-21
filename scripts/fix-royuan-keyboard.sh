#!/bin/bash
#
# ROYUAN OLV75 Keyboard Fix Script
# This script fixes the fnmode issue for the ROYUAN OLV75 keyboard
# when function keys are not working as expected
#
# Usage: fix-royuan-keyboard [--check|--apply|--install]
#

set -e

# Ensure we have access to system binaries
export PATH="/usr/bin:/usr/sbin:$PATH"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Keyboard details
KEYBOARD_NAME="ROYUAN OLV75"
VENDOR_ID="05ac"
PRODUCT_ID="024f"
DESIRED_FNMODE=2

# Configuration files
MODPROBE_CONF="/etc/modprobe.d/hid_apple.conf"
SYSTEMD_SERVICE="/etc/systemd/system/royuan-keyboard-fix.service"
BACKUP_DIR="/etc/royuan-keyboard-backup"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  ROYUAN OLV75 Keyboard Fix Script${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

check_keyboard() {
    echo -e "${YELLOW}Checking for ROYUAN OLV75 keyboard...${NC}"

    # Find lsusb command
    LSUSB_CMD=""
    if command -v lsusb &> /dev/null; then
        LSUSB_CMD="lsusb"
    elif [ -x /usr/bin/lsusb ]; then
        LSUSB_CMD="/usr/bin/lsusb"
    fi

    if [ -z "$LSUSB_CMD" ]; then
        echo -e "${RED}✗ lsusb command not found${NC}"
        echo "  Please install usbutils package:"
        echo "    On Arch/CachyOS: sudo pacman -S usbutils"
        echo "    Or run: home-manager switch --flake ~/.config/nix#archlinux"
        return 1
    fi

    if $LSUSB_CMD | grep -q "${VENDOR_ID}:${PRODUCT_ID}"; then
        echo -e "${GREEN}✓ ROYUAN OLV75 keyboard detected${NC}"
        $LSUSB_CMD | grep "${VENDOR_ID}:${PRODUCT_ID}"
        return 0
    else
        echo -e "${RED}✗ ROYUAN OLV75 keyboard not detected${NC}"
        echo "  Please make sure the keyboard is connected."
        return 1
    fi
}

check_current_fnmode() {
    echo ""
    echo -e "${YELLOW}Checking current fnmode setting...${NC}"

    if [ -f /sys/module/hid_apple/parameters/fnmode ]; then
        CURRENT_FNMODE=$(cat /sys/module/hid_apple/parameters/fnmode)
        echo -e "  Current fnmode: ${CURRENT_FNMODE}"

        if [ "$CURRENT_FNMODE" -eq "$DESIRED_FNMODE" ]; then
            echo -e "${GREEN}✓ fnmode is already set to ${DESIRED_FNMODE}${NC}"
            return 0
        else
            echo -e "${RED}✗ fnmode is ${CURRENT_FNMODE}, should be ${DESIRED_FNMODE}${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ hid_apple module not loaded or fnmode parameter not available${NC}"
        return 1
    fi
}

apply_fnmode_fix() {
    echo ""
    echo -e "${YELLOW}Applying fnmode fix...${NC}"

    if [ ! -f /sys/module/hid_apple/parameters/fnmode ]; then
        echo -e "${RED}✗ Cannot apply fix: hid_apple module not loaded${NC}"
        return 1
    fi

    echo "  Setting fnmode to ${DESIRED_FNMODE}..."
    echo ${DESIRED_FNMODE} | sudo tee /sys/module/hid_apple/parameters/fnmode > /dev/null

    CURRENT_FNMODE=$(cat /sys/module/hid_apple/parameters/fnmode)
    if [ "$CURRENT_FNMODE" -eq "$DESIRED_FNMODE" ]; then
        echo -e "${GREEN}✓ fnmode successfully set to ${DESIRED_FNMODE}${NC}"
        echo -e "${GREEN}  Your function keys should now work!${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to set fnmode${NC}"
        return 1
    fi
}

check_persistent_config() {
    echo ""
    echo -e "${YELLOW}Checking persistent configuration...${NC}"

    local all_good=true

    # Check systemd service
    if [ -f "$SYSTEMD_SERVICE" ]; then
        echo -e "${GREEN}✓ Systemd service exists: ${SYSTEMD_SERVICE}${NC}"
        if systemctl is-enabled royuan-keyboard-fix.service &>/dev/null; then
            echo -e "${GREEN}  Service is enabled${NC}"
        else
            echo -e "${YELLOW}  Service exists but is not enabled${NC}"
            all_good=false
        fi
    else
        echo -e "${RED}✗ Systemd service missing: ${SYSTEMD_SERVICE}${NC}"
        all_good=false
    fi

    # Check modprobe config
    if [ -f "$MODPROBE_CONF" ]; then
        echo -e "${GREEN}✓ Modprobe config exists: ${MODPROBE_CONF}${NC}"
    else
        echo -e "${RED}✗ Modprobe config missing: ${MODPROBE_CONF}${NC}"
        all_good=false
    fi

    # Check for backups
    if [ -d "$BACKUP_DIR" ]; then
        local backup_count=$(find "$BACKUP_DIR" -type f 2>/dev/null | wc -l)
        if [ "$backup_count" -gt 0 ]; then
            echo -e "${BLUE}ℹ Backups found: $backup_count file(s) in ${BACKUP_DIR}${NC}"
        fi
    fi

    if [ "$all_good" = true ]; then
        return 0
    else
        return 1
    fi
}

backup_file() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        return 0
    fi

    # Create backup directory if it doesn't exist
    sudo mkdir -p "$BACKUP_DIR"

    local filename=$(basename "$file_path")
    local backup_path="${BACKUP_DIR}/${filename}.${BACKUP_TIMESTAMP}.bak"

    echo "  Backing up existing file: $file_path"
    sudo cp "$file_path" "$backup_path"

    if [ -f "$backup_path" ]; then
        echo -e "${GREEN}  ✓ Backup created: $backup_path${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Failed to create backup${NC}"
        return 1
    fi
}

install_persistent_config() {
    echo ""
    echo -e "${YELLOW}Installing persistent configuration...${NC}"
    echo ""

    # Backup existing files
    echo -e "${BLUE}Backing up existing configurations...${NC}"
    backup_file "$MODPROBE_CONF" || true
    backup_file "$SYSTEMD_SERVICE" || true

    # Create modprobe config
    echo ""
    echo "  Creating modprobe config..."
    sudo tee "$MODPROBE_CONF" > /dev/null << 'EOF'
# Configuration for Apple keyboards (ROYUAN OLV75)
# Managed by fix-royuan-keyboard script
#
# fnmode options:
#   0 = disabled (no special function key behavior)
#   1 = media keys by default (Fn key switches to F1-F12)
#   2 = F1-F12 by default (Fn key switches to media keys)
#
# Setting fnmode=2 for ROYUAN OLV75 keyboard
options hid_apple fnmode=2
EOF

    if [ -f "$MODPROBE_CONF" ]; then
        echo -e "${GREEN}✓ Modprobe config created${NC}"
    else
        echo -e "${RED}✗ Failed to create modprobe config${NC}"
        return 1
    fi

    # Create systemd service (fallback method)
    echo "  Creating systemd service..."
    sudo tee "$SYSTEMD_SERVICE" > /dev/null << 'EOF'
[Unit]
Description=Fix ROYUAN OLV75 Keyboard fnmode
After=systemd-modules-load.service
Documentation=https://github.com/yourusername/nix-config

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 2 > /sys/module/hid_apple/parameters/fnmode'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    if [ -f "$SYSTEMD_SERVICE" ]; then
        echo -e "${GREEN}✓ Systemd service created${NC}"
    else
        echo -e "${RED}✗ Failed to create systemd service${NC}"
        return 1
    fi

    # Enable systemd service
    echo "  Enabling systemd service..."
    sudo systemctl daemon-reload
    sudo systemctl enable royuan-keyboard-fix.service 2>/dev/null
    echo -e "${GREEN}✓ Systemd service enabled${NC}"

    # Regenerate initramfs
    echo "  Regenerating initramfs (this may take a moment)..."
    sudo mkinitcpio -P > /dev/null 2>&1
    echo -e "${GREEN}✓ Initramfs regenerated${NC}"

    echo ""
    echo -e "${GREEN}✓ Persistent configuration installed successfully!${NC}"
    echo -e "  ${BLUE}Installation summary:${NC}"
    echo -e "    • Modprobe config: Sets fnmode=2 at module load"
    echo -e "    • Systemd service: Ensures fnmode=2 after boot (fallback)"
    echo -e "    • Backups saved to: ${BACKUP_DIR}"
    echo ""
    echo -e "  ${YELLOW}Note: Reboot for changes to take full effect${NC}"
    echo -e "  Or run: ${BLUE}fix-royuan-keyboard --apply${NC} for immediate fix"

    return 0
}

revert_config() {
    echo ""
    echo -e "${YELLOW}Reverting configuration...${NC}"
    echo ""

    local reverted=false

    # Check if backup directory exists
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}No backup directory found at ${BACKUP_DIR}${NC}"
        echo -e "${YELLOW}Will only remove installed configurations${NC}"
    else
        echo -e "${BLUE}Found backups in ${BACKUP_DIR}${NC}"
        echo ""

        # Restore modprobe config
        local modprobe_backup=$(find "$BACKUP_DIR" -name "hid_apple.conf.*.bak" -type f 2>/dev/null | sort -r | head -1)
        if [ -n "$modprobe_backup" ]; then
            echo "  Restoring modprobe config from backup..."
            sudo cp "$modprobe_backup" "$MODPROBE_CONF"
            echo -e "${GREEN}  ✓ Restored: $MODPROBE_CONF${NC}"
            reverted=true
        elif [ -f "$MODPROBE_CONF" ]; then
            echo "  No backup found for modprobe config, removing current file..."
            sudo rm -f "$MODPROBE_CONF"
            echo -e "${GREEN}  ✓ Removed: $MODPROBE_CONF${NC}"
            reverted=true
        fi

        # Handle systemd service (no need to restore, just remove)
        if [ -f "$SYSTEMD_SERVICE" ]; then
            echo "  Disabling and removing systemd service..."
            sudo systemctl disable royuan-keyboard-fix.service 2>/dev/null || true
            sudo rm -f "$SYSTEMD_SERVICE"
            sudo systemctl daemon-reload
            echo -e "${GREEN}  ✓ Removed: $SYSTEMD_SERVICE${NC}"
            reverted=true
        fi
    fi

    if [ "$reverted" = false ]; then
        echo -e "${YELLOW}No configurations to revert${NC}"
        return 0
    fi

    # Regenerate initramfs
    echo ""
    echo "  Regenerating initramfs..."
    sudo mkinitcpio -P > /dev/null 2>&1
    echo -e "${GREEN}✓ Initramfs regenerated${NC}"

    echo ""
    echo -e "${GREEN}✓ Configuration reverted successfully!${NC}"
    echo -e "  ${BLUE}What was done:${NC}"
    echo -e "    • Restored backed-up configurations (if available)"
    echo -e "    • Removed ROYUAN keyboard fix configurations"
    echo -e "    • Disabled systemd service"
    echo ""
    echo -e "  ${YELLOW}Note: Reboot for changes to take full effect${NC}"
    echo -e "  Backups are preserved in: ${BACKUP_DIR}"

    return 0
}

list_backups() {
    echo ""
    echo -e "${BLUE}Backup Information${NC}"
    echo -e "${BLUE}==================${NC}"
    echo ""

    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}No backup directory found${NC}"
        return 0
    fi

    local backup_files=$(find "$BACKUP_DIR" -type f 2>/dev/null)
    if [ -z "$backup_files" ]; then
        echo -e "${YELLOW}Backup directory is empty${NC}"
        return 0
    fi

    echo -e "Backup location: ${BACKUP_DIR}"
    echo ""
    echo "Available backups:"
    find "$BACKUP_DIR" -type f -exec ls -lh {} \; | awk '{print "  " $9 " (" $5 ", " $6 " " $7 " " $8 ")"}'

    return 0
}

show_usage() {
    cat << EOF
Usage: fix-royuan-keyboard [OPTION]

Fix function key issues for ROYUAN OLV75 keyboard on Linux.

OPTIONS:
    --check         Check keyboard status and current configuration
    --apply         Apply the fnmode fix immediately (temporary until reboot)
    --install       Install persistent configuration with backup
    --revert        Restore from backup and remove configurations
    --list-backups  Show all available backups
    --help          Show this help message

If no option is specified, runs --check and --apply.

EXAMPLES:
    fix-royuan-keyboard                # Quick fix (check and apply)
    fix-royuan-keyboard --check        # Only check status
    fix-royuan-keyboard --install      # Install persistent config with backup
    fix-royuan-keyboard --revert       # Restore previous configuration
    fix-royuan-keyboard --list-backups # Show backup files

CONFIGURATION:
    This script uses a dual-method approach for reliability:
    1. Modprobe config - Sets fnmode=2 when hid_apple module loads
    2. Systemd service - Ensures fnmode=2 after boot (fallback)

    All changes are backed up before installation.

EOF
}

# Main script logic
main() {
    print_header

    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --check)
            check_keyboard
            check_current_fnmode
            check_persistent_config
            ;;
        --apply)
            check_keyboard && apply_fnmode_fix
            ;;
        --install)
            install_persistent_config
            ;;
        --revert)
            revert_config
            ;;
        --list-backups)
            list_backups
            ;;
        "")
            # Default: check and apply
            if check_keyboard; then
                if ! check_current_fnmode; then
                    apply_fnmode_fix
                fi
                check_persistent_config
            fi
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac

    echo ""
    echo -e "${BLUE}========================================${NC}"
}

main "$@"
