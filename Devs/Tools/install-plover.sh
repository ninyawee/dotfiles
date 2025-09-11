#!/usr/bin/env bash
# Install and integrate Plover AppImage

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPIMAGE_PATH="$SCRIPT_DIR/plover-5.0.0rc1-x86_64.AppImage"

# Check if AppImage exists
if [[ ! -f "$APPIMAGE_PATH" ]]; then
    echo "Error: Plover AppImage not found at $APPIMAGE_PATH"
    echo "Run 'chezmoi apply' first to download it."
    exit 1
fi

# Make AppImage executable if not already
chmod +x "$APPIMAGE_PATH"

# Create applications directory if it doesn't exist
mkdir -p ~/.local/share/applications

# Create desktop file
cat > ~/.local/share/applications/plover.desktop << EOF
[Desktop Entry]
Type=Application
Name=Plover
Comment=Open source stenography engine
Exec=$APPIMAGE_PATH
Icon=plover
Terminal=false
Categories=Utility;Accessibility;
StartupNotify=true
EOF

# Create Wayland-compatible launcher script
LAUNCHER_SCRIPT="$HOME/.local/bin/plover-wayland"
mkdir -p ~/.local/bin

cat > "$LAUNCHER_SCRIPT" << EOF
#!/usr/bin/env bash
# Plover launcher with Wayland support
xhost +si:localuser:\$USER 2>/dev/null || true
exec "$APPIMAGE_PATH" "\$@"
EOF

chmod +x "$LAUNCHER_SCRIPT"

# Create desktop file for Wayland version
cat > ~/.local/share/applications/plover-wayland.desktop << EOF
[Desktop Entry]
Type=Application
Name=Plover (Wayland)
Comment=Open source stenography engine (Wayland compatible)
Exec=$LAUNCHER_SCRIPT
Icon=plover
Terminal=false
Categories=Utility;Accessibility;
StartupNotify=true
EOF

# Download Plover icon if possible
ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"
mkdir -p "$ICON_DIR"

if command -v wget >/dev/null 2>&1; then
    echo "Downloading Plover icon..."
    wget -q -O "$ICON_DIR/plover.png" \
        "https://github.com/openstenoproject/plover/raw/main/plover/gui_qt/resources/plover.png" \
        || echo "Warning: Could not download icon, using default"
fi

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database ~/.local/share/applications
fi

echo "✓ Plover AppImage integration complete!"
echo "✓ Created desktop entries for both X11 and Wayland"
echo "✓ Launcher script created at $LAUNCHER_SCRIPT"
echo ""
echo "You can now:"
echo "  - Find 'Plover' in your application menu"
echo "  - Run 'plover-wayland' from terminal"
echo "  - Run the AppImage directly: $APPIMAGE_PATH"
echo ""
echo "Note: Log out and back in if the application doesn't appear in your menu."