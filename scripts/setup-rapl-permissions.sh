#!/bin/bash
# Setup Intel RAPL permissions for power monitoring
# This allows reading CPU power consumption without sudo

UDEV_RULE_FILE="/etc/udev/rules.d/90-intel-rapl.rules"
UDEV_RULE_CONTENT='# Allow users to read Intel RAPL energy monitoring
SUBSYSTEM=="powercap", KERNEL=="intel-rapl:*", RUN+="/bin/chmod 0755 $sys$devpath", RUN+="/bin/chmod -R 0444 $sys$devpath/*"'

# Check if running with sudo/root
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Do not run this script with sudo. It will prompt for password when needed."
    exit 1
fi

# Check if rule already exists
if [ -f "$UDEV_RULE_FILE" ]; then
    echo "✓ RAPL udev rule already installed at $UDEV_RULE_FILE"

    # Apply permissions immediately
    if [ -d "/sys/class/powercap/intel-rapl:0" ]; then
        sudo chmod 0755 /sys/devices/virtual/powercap/intel-rapl/intel-rapl:* 2>/dev/null
        sudo chmod -R 0444 /sys/devices/virtual/powercap/intel-rapl/intel-rapl:*/energy_uj 2>/dev/null
        echo "✓ RAPL permissions applied"
    fi
    exit 0
fi

# Create and install udev rule
echo "📝 Installing RAPL udev rule..."
echo "$UDEV_RULE_CONTENT" | sudo tee "$UDEV_RULE_FILE" > /dev/null

if [ $? -eq 0 ]; then
    echo "✓ Udev rule installed"

    # Reload udev rules
    echo "🔄 Reloading udev rules..."
    sudo udevadm control --reload-rules 2>/dev/null
    sudo udevadm trigger 2>/dev/null

    # Apply permissions immediately for current session
    if [ -d "/sys/class/powercap/intel-rapl:0" ]; then
        sudo chmod 0755 /sys/devices/virtual/powercap/intel-rapl/intel-rapl:* 2>/dev/null
        sudo chmod -R 0444 /sys/devices/virtual/powercap/intel-rapl/intel-rapl:*/energy_uj 2>/dev/null
        echo "✓ RAPL permissions applied"
    fi

    echo "✅ CPU power monitoring is now enabled"
else
    echo "❌ Failed to install udev rule"
    exit 1
fi
