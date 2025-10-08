#!/bin/bash
# Load Tactile dconf settings
# Hash: {{ include (joinPath .chezmoi.homeDir ".local/share/dconf/tactile.conf") | sha256sum }}

if [ -f "${HOME}/.local/share/dconf/tactile.conf" ]; then
    dconf load /org/gnome/shell/extensions/tactile/ < "${HOME}/.local/share/dconf/tactile.conf"
    echo "Loaded Tactile dconf settings"
fi
