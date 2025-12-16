#!/bin/bash
# Setup Apple keyboard fnmode to use F1-F12 as function keys by default
# This makes the fn key work properly on Apple/Mac keyboards

set -e

CONF_FILE="/etc/modprobe.d/hid_apple.conf"
EXPECTED_CONTENT="options hid_apple fnmode=2"

# Check if already configured
if [ -f "$CONF_FILE" ] && grep -q "fnmode=2" "$CONF_FILE"; then
    echo "Apple fnmode already configured"
    exit 0
fi

echo "Setting up Apple keyboard fnmode..."

# Create modprobe config
echo "$EXPECTED_CONTENT" | sudo tee "$CONF_FILE" > /dev/null

# Update initramfs so it persists across reboots
sudo update-initramfs -u

# Apply immediately without reboot
if [ -f /sys/module/hid_apple/parameters/fnmode ]; then
    echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode > /dev/null
fi

echo "Apple fnmode configured successfully"
