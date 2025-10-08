# Custom Keyboard Layouts for Ubuntu/GNOME

This directory contains scripts to install and configure **Graphite** (English) and **Manoonchai** (Thai) keyboard layouts on Ubuntu with GNOME.

## Overview

- **Graphite**: An optimized English keyboard layout
- **Manoonchai**: An efficient Thai keyboard layout (v1.0)

## Quick Start

```bash
# Install both keyboard layouts
sudo ./keyboards/scripts/install-keyboard-layouts.sh

# Configure GNOME input sources (user session)
./keyboards/scripts/configure-gnome-input.sh

# Configure login screen input sources (separate script with menu)
sudo ./keyboards/scripts/configure-gdm-input.sh

# Reboot for full effect
sudo reboot
```

## Directory Structure

```
keyboards/
├── layouts/
│   ├── manoonchai/
│   │   ├── Manoonchai_xkb              # Manoonchai layout definition
│   │   ├── manoonchai_lowercase.patch  # Patch for lowercase naming
│   │   └── executable_installmanoonchai.sh  # Original Manoonchai installer
│   └── graphite/
│       └── graphite-layout/            # External Graphite layout repo (auto-downloaded)
└── scripts/
    ├── executable_install-keyboard-layouts.sh    # Main installation script
    ├── executable_configure-gnome-input.sh       # GNOME user session config
    ├── executable_configure-gdm-input.sh         # GDM login screen config
    ├── executable_apply-manoonchai-patch.sh      # Manual patch application
    ├── executable_fix-manoonchai-duplicates.sh   # Fix duplicate entries
    └── executable_install-plover.sh              # Plover stenography software installer
```

## Files Description

### Installation Scripts

- **`keyboards/scripts/install-keyboard-layouts.sh`** - Main installation script that:
  - Automatically patches Manoonchai to use lowercase naming (manoonchai instead of ThaiMnc)
  - Installs both Graphite and Manoonchai layouts
  - Verifies installation
  - Requires sudo

- **`keyboards/layouts/manoonchai/executable_installmanoonchai.sh`** - Original Manoonchai installation script
- **`keyboards/layouts/graphite/graphite-layout/linux/install.sh`** - Original Graphite installation script

### Configuration Scripts

- **`keyboards/scripts/configure-gnome-input.sh`** - Configures GNOME input sources for user session:
  - Configures current user session only
  - References separate GDM script for login screen configuration
  - Run with `--debug` to see current configuration

- **`keyboards/scripts/configure-gdm-input.sh`** - Configures GDM login screen input sources:
  - Interactive menu with 6 configuration options
  - Requires sudo privileges
  - Uses multiple methods for maximum compatibility

### Layout Files

- **`keyboards/layouts/manoonchai/Manoonchai_xkb`** - Manoonchai keyboard layout definition
- **`keyboards/layouts/graphite/graphite-layout/linux/graphite`** - Graphite keyboard layout definition

### Patch Files

- **`keyboards/layouts/manoonchai/manoonchai_lowercase.patch`** - Patch to change ThaiMnc to manoonchai
- **`keyboards/scripts/apply-manoonchai-patch.sh`** - Manual patch application script (not needed with auto-patch)

### Stenography Software

- **`keyboards/scripts/install-plover.sh`** - Installs and integrates Plover stenography software:
  - Sets up Plover AppImage with desktop integration
  - Creates Wayland-compatible launcher
  - Downloads application icon
  - Requires the Plover AppImage to be downloaded first via `chezmoi apply`

## Detailed Usage

### Installing Layouts

```bash
sudo ./keyboards/scripts/install-keyboard-layouts.sh
```

This will:
1. Check for required tools (xsltproc)
2. Auto-patch Manoonchai to use lowercase naming
3. Install Manoonchai as `th+manoonchai`
4. Install Graphite as `us+graphite`
5. Verify installations

### Configuring Input Sources

For user session only:
```bash
./keyboards/scripts/configure-gnome-input.sh
```

For login screen (interactive menu):
```bash
sudo ./keyboards/scripts/configure-gdm-input.sh
```

### Installing Plover Stenography Software

```bash
# First ensure the AppImage is downloaded
chezmoi apply

# Then install and integrate Plover
./keyboards/scripts/install-plover.sh
```

The GDM script offers these configuration methods:
1. dconf database configuration
2. localectl system-wide configuration  
3. GDM user direct configuration
4. /etc/default/keyboard configuration
5. GDM greeter defaults configuration
6. All methods (recommended)

### Debugging

Check current configuration:
```bash
./keyboards/scripts/configure-gnome-input.sh --debug
```

Check system keyboard settings:
```bash
localectl status
gsettings get org.gnome.desktop.input-sources sources
```

## Keyboard Shortcuts

After installation:
- **Super+Space** or **Alt+Shift**: Switch between input sources
- Configure more shortcuts in: Settings → Keyboard → Input Sources

## Troubleshooting

### Login screen doesn't show the layouts

The script uses multiple configuration methods for compatibility. After running with sudo, try:

1. Restart GDM service:
   ```bash
   sudo systemctl restart gdm
   ```

2. Or reboot the system:
   ```bash
   sudo reboot
   ```

### Layouts not appearing in GNOME Settings

1. Verify installation:
   ```bash
   grep -q "manoonchai" /usr/share/X11/xkb/symbols/th && echo "Manoonchai installed"
   grep -q "graphite" /usr/share/X11/xkb/symbols/us && echo "Graphite installed"
   ```

2. Re-run installation:
   ```bash
   sudo ./keyboards/scripts/install-keyboard-layouts.sh
   ```

3. Log out and log back in

### Reset to default

To remove custom layouts:

1. Restore backups (created with timestamps):
   ```bash
   ls /usr/share/X11/xkb/symbols/*.bak
   ls /usr/share/X11/xkb/rules/*.bak
   ```

2. Reset GNOME settings:
   ```bash
   gsettings reset org.gnome.desktop.input-sources sources
   ```

## Technical Details

### Installation Process

1. **Manoonchai**: 
   - Patches layout ID from "ThaiMnc" to "manoonchai" for consistency
   - Adds to `/usr/share/X11/xkb/symbols/th`
   - Registers in XKB rules files

2. **Graphite**:
   - Adds to `/usr/share/X11/xkb/symbols/us`
   - Uses XSLT to modify XKB registry

### GDM Configuration Methods

The `keyboards/scripts/configure-gdm-input.sh` script provides an interactive menu with these methods:

1. **dconf database** (`/etc/dconf/db/gdm.d/`) - Creates GDM-specific dconf settings
2. **localectl** (system-wide X11 keymap) - Uses systemd's keyboard configuration
3. **GDM user gsettings** - Configures the gdm user directly
4. **`/etc/default/keyboard`** - Traditional Debian/Ubuntu keyboard configuration
5. **GDM greeter defaults** (`/etc/gdm3/greeter.dconf-defaults`) - GDM3-specific settings
6. **All methods** - Applies all methods for maximum compatibility (recommended)

## Requirements

- Ubuntu with GNOME (tested on Ubuntu 22.04/24.04)
- sudo privileges for installation
- xsltproc (auto-installed if missing)

## License

- Manoonchai layout: MIT License
- Graphite layout: See graphite-layout repository
- Scripts: MIT License

## Contributing

Feel free to report issues or submit improvements!

## Credits

- Manoonchai: Thai keyboard layout community
- Graphite: Graphite keyboard layout project
- Installation scripts: Enhanced for Ubuntu/GNOME compatibility