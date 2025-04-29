#!/bin/bash
# Sets up systemd user service for Atuin daemon on ZFS systems

# Create systemd user directory if it doesn't exist
mkdir -p ~/.config/systemd/user/

# Create the service file with the correct path to atuin
cat > ~/.config/systemd/user/atuin.service << EOF
[Unit]
Description=Atuin daemon service
Documentation=https://docs.atuin.sh
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=$(which atuin) daemon

[Install]
WantedBy=default.target
EOF

# Reload systemd user daemon
systemctl --user daemon-reload

# Enable and start the service
systemctl --user enable atuin.service
systemctl --user start atuin.service

echo "Atuin daemon is now set up with systemd and running"