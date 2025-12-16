#!/bin/bash
# Setup kanata keyboard remapper
# - Creates uinput group and adds user
# - Sets up udev rules for /dev/uinput
# - Loads uinput module on boot
# - Installs kanata via cargo
# - Enables systemd user service

set -e

echo "Setting up kanata keyboard remapper..."

# Check if uinput group exists
if ! getent group uinput > /dev/null 2>&1; then
    echo "Creating uinput group..."
    sudo groupadd uinput
fi

# Add user to uinput and input groups
if ! groups "$USER" | grep -q '\buinput\b'; then
    echo "Adding $USER to uinput group..."
    sudo usermod -aG uinput "$USER"
fi

if ! groups "$USER" | grep -q '\binput\b'; then
    echo "Adding $USER to input group..."
    sudo usermod -aG input "$USER"
fi

# Create udev rule for uinput
UDEV_RULE="/etc/udev/rules.d/99-uinput.rules"
EXPECTED_RULE='KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"'

if [ ! -f "$UDEV_RULE" ] || ! grep -q 'GROUP="uinput"' "$UDEV_RULE"; then
    echo "Creating udev rule for uinput..."
    echo "$EXPECTED_RULE" | sudo tee "$UDEV_RULE" > /dev/null
    sudo udevadm control --reload-rules
    sudo udevadm trigger
fi

# Load uinput module
if ! lsmod | grep -q '^uinput'; then
    echo "Loading uinput module..."
    sudo modprobe uinput
fi

# Ensure uinput loads on boot
MODULES_FILE="/etc/modules-load.d/uinput.conf"
if [ ! -f "$MODULES_FILE" ] || ! grep -q 'uinput' "$MODULES_FILE"; then
    echo "Configuring uinput to load on boot..."
    echo "uinput" | sudo tee "$MODULES_FILE" > /dev/null
fi

# Install kanata if not present
if ! command -v kanata &> /dev/null; then
    echo "Installing kanata via cargo..."
    cargo install kanata
fi

# Reload systemd user daemon
systemctl --user daemon-reload

# Enable kanata service (but don't start - need re-login for groups)
systemctl --user enable kanata.service 2>/dev/null || true

echo ""
echo "Kanata setup complete!"
echo ""
echo "NOTE: You need to log out and log back in for group changes to take effect."
echo "After re-login, start kanata with: systemctl --user start kanata.service"
