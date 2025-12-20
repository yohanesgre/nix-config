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
UDEV_RULE="/etc/udev/rules.d/99-royuan-keyboard.rules"

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

    # Check udev rule
    if [ -f "$UDEV_RULE" ]; then
        echo -e "${GREEN}✓ Udev rule exists: ${UDEV_RULE}${NC}"
    else
        echo -e "${RED}✗ Udev rule missing: ${UDEV_RULE}${NC}"
        all_good=false
    fi

    # Check modprobe config
    if [ -f "$MODPROBE_CONF" ]; then
        echo -e "${GREEN}✓ Modprobe config exists: ${MODPROBE_CONF}${NC}"
    else
        echo -e "${RED}✗ Modprobe config missing: ${MODPROBE_CONF}${NC}"
        all_good=false
    fi

    if [ "$all_good" = true ]; then
        return 0
    else
        return 1
    fi
}

install_persistent_config() {
    echo ""
    echo -e "${YELLOW}Installing persistent configuration...${NC}"

    # Create udev rule
    echo "  Creating udev rule..."
    sudo tee "$UDEV_RULE" > /dev/null << 'EOF'
# ROYUAN OLV75 Keyboard - Set fnmode to 2 for F1-F12 as default
# This rule applies only to the ROYUAN OLV75 (USB ID: 05ac:024f)
ACTION=="add", SUBSYSTEM=="hid", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="024f", RUN+="/bin/sh -c 'echo 2 > /sys/module/hid_apple/parameters/fnmode'"
EOF

    if [ -f "$UDEV_RULE" ]; then
        echo -e "${GREEN}✓ Udev rule created${NC}"
    else
        echo -e "${RED}✗ Failed to create udev rule${NC}"
        return 1
    fi

    # Create modprobe config
    echo "  Creating modprobe config..."
    sudo tee "$MODPROBE_CONF" > /dev/null << 'EOF'
# Configuration for Apple keyboards
#
# IMPORTANT: Device-specific settings are handled by udev rules
# See /etc/udev/rules.d/99-royuan-keyboard.rules for ROYUAN OLV75 configuration
#
# This is the default fnmode for other Apple keyboards:
# fnmode options:
#   0 = disabled (no special function key behavior)
#   1 = media keys by default (Fn key switches to F1-F12)
#   2 = F1-F12 by default (Fn key switches to media keys)
#
# Default setting for other Apple keyboards (change if needed)
options hid_apple fnmode=1
EOF

    if [ -f "$MODPROBE_CONF" ]; then
        echo -e "${GREEN}✓ Modprobe config created${NC}"
    else
        echo -e "${RED}✗ Failed to create modprobe config${NC}"
        return 1
    fi

    # Reload udev rules
    echo "  Reloading udev rules..."
    sudo udevadm control --reload-rules 2>/dev/null
    echo -e "${GREEN}✓ Udev rules reloaded${NC}"

    # Regenerate initramfs
    echo "  Regenerating initramfs (this may take a moment)..."
    sudo mkinitcpio -P > /dev/null 2>&1
    echo -e "${GREEN}✓ Initramfs regenerated${NC}"

    echo ""
    echo -e "${GREEN}✓ Persistent configuration installed successfully!${NC}"
    echo -e "  The fix will persist across reboots."

    return 0
}

show_usage() {
    cat << EOF
Usage: fix-royuan-keyboard [OPTION]

Fix function key issues for ROYUAN OLV75 keyboard on Linux.

OPTIONS:
    --check     Check keyboard status and current configuration
    --apply     Apply the fnmode fix immediately (temporary until reboot)
    --install   Install persistent configuration files
    --help      Show this help message

If no option is specified, runs --check and --apply.

EXAMPLES:
    fix-royuan-keyboard              # Quick fix (check and apply)
    fix-royuan-keyboard --check      # Only check status
    fix-royuan-keyboard --install    # Install persistent config

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
