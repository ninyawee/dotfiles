#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Keyboard layouts to configure
LAYOUTS="us+graphite,th+manoonchai"
GSETTINGS_VALUE="[('xkb', 'us+graphite'), ('xkb', 'th+manoonchai')]"

# Function to show menu and get user choice
show_menu() {
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}  GDM Login Screen Configuration${NC}"
    echo -e "${GREEN}=================================================${NC}"
    echo
    echo -e "${CYAN}Choose GDM configuration method:${NC}"
    echo "1) Method 1: dconf database configuration"
    echo "2) Method 2: localectl system-wide configuration"
    echo "3) Method 3: GDM user direct configuration"
    echo "4) Method 4: /etc/default/keyboard configuration"
    echo "5) Method 5: GDM greeter defaults configuration"
    echo "6) All methods (recommended)"
    echo "0) Exit"
    echo
}

# Function to configure GDM using dconf database
configure_gdm_dconf() {
    echo -e "${CYAN}Method 1: Configuring dconf database...${NC}"
    
    # Create GDM configuration directory if it doesn't exist
    GDM_CONFIG_DIR="/etc/dconf/db/gdm.d"
    if [[ ! -d "$GDM_CONFIG_DIR" ]]; then
        mkdir -p "$GDM_CONFIG_DIR"
    fi
    
    # Create GDM input sources configuration with higher priority
    cat > "${GDM_CONFIG_DIR}/10-input-sources" << EOF
[org/gnome/desktop/input-sources]
sources=$GSETTINGS_VALUE
show-all-sources=true
per-window=false
xkb-options=['grp:alt_shift_toggle']
EOF
    echo -e "${GREEN}✓ Created ${GDM_CONFIG_DIR}/10-input-sources${NC}"
    
    # Create profile configuration if it doesn't exist
    DCONF_PROFILE="/etc/dconf/profile/gdm"
    if [[ ! -f "$DCONF_PROFILE" ]]; then
        cat > "$DCONF_PROFILE" << EOF
user-db:user
system-db:gdm
EOF
        echo -e "${GREEN}✓ Created dconf profile at ${DCONF_PROFILE}${NC}"
    fi
    
    # Update dconf database
    echo -e "${GREEN}Updating dconf database...${NC}"
    dconf update
    echo -e "${GREEN}✓ dconf database method completed${NC}"
}

# Function to configure using localectl
configure_gdm_localectl() {
    echo -e "${CYAN}Method 2: Using localectl for system-wide configuration...${NC}"
    
    # Set X11 keyboard layout using localectl
    if command -v localectl >/dev/null 2>&1; then
        echo -e "${GREEN}Setting X11 keyboard layout with localectl...${NC}"
        # Note: localectl doesn't support variants with +, so we use the base layouts
        localectl set-x11-keymap "us,th" "pc105" "graphite,manoonchai" "grp:alt_shift_toggle" 2>/dev/null || {
            echo -e "${YELLOW}Warning: localectl command failed, trying alternative syntax...${NC}"
            localectl set-x11-keymap "us,th" "" "" "" 2>/dev/null || true
        }
        echo -e "${GREEN}✓ localectl method completed${NC}"
    else
        echo -e "${RED}localectl not found${NC}"
    fi
}

# Function to configure GDM user directly
configure_gdm_user() {
    echo -e "${CYAN}Method 3: Configuring GDM user directly...${NC}"
    
    # Configure gdm user if it exists
    if id "gdm" &>/dev/null; then
        echo -e "${GREEN}Setting input sources for GDM user...${NC}"
        sudo -u gdm dbus-launch gsettings set org.gnome.desktop.input-sources sources "$GSETTINGS_VALUE" 2>/dev/null || true
        sudo -u gdm dbus-launch gsettings set org.gnome.desktop.input-sources show-all-sources true 2>/dev/null || true
        echo -e "${GREEN}✓ GDM user method completed${NC}"
    else
        echo -e "${YELLOW}GDM user not found${NC}"
    fi
}

# Function to configure /etc/default/keyboard
configure_gdm_keyboard() {
    echo -e "${CYAN}Method 4: Updating /etc/default/keyboard...${NC}"
    
    # Backup and update /etc/default/keyboard
    if [[ -f /etc/default/keyboard ]]; then
        cp /etc/default/keyboard /etc/default/keyboard.backup
        cat > /etc/default/keyboard << EOF
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="us,th"
XKBVARIANT="graphite,manoonchai"
XKBOPTIONS="grp:alt_shift_toggle"

BACKSPACE="guess"
EOF
        echo -e "${GREEN}✓ Updated /etc/default/keyboard${NC}"
        
        # Apply the configuration
        if command -v dpkg-reconfigure >/dev/null 2>&1; then
            dpkg-reconfigure -phigh keyboard-configuration 2>/dev/null || true
        fi
        echo -e "${GREEN}✓ keyboard configuration method completed${NC}"
    else
        echo -e "${YELLOW}/etc/default/keyboard not found${NC}"
    fi
}

# Function to configure GDM greeter defaults
configure_gdm_greeter() {
    echo -e "${CYAN}Method 5: Adding to GDM greeter defaults...${NC}"
    
    # Add to /etc/gdm3/greeter.dconf-defaults if it exists
    if [[ -f /etc/gdm3/greeter.dconf-defaults ]]; then
        # Check if input-sources section already exists
        if ! grep -q "\[org/gnome/desktop/input-sources\]" /etc/gdm3/greeter.dconf-defaults; then
            echo "" >> /etc/gdm3/greeter.dconf-defaults
            echo "[org/gnome/desktop/input-sources]" >> /etc/gdm3/greeter.dconf-defaults
            echo "sources=$GSETTINGS_VALUE" >> /etc/gdm3/greeter.dconf-defaults
            echo "show-all-sources=true" >> /etc/gdm3/greeter.dconf-defaults
            echo -e "${GREEN}✓ Added to /etc/gdm3/greeter.dconf-defaults${NC}"
        else
            echo -e "${YELLOW}Input sources section already exists in greeter.dconf-defaults${NC}"
        fi
        echo -e "${GREEN}✓ greeter defaults method completed${NC}"
    else
        echo -e "${YELLOW}/etc/gdm3/greeter.dconf-defaults not found${NC}"
    fi
}

# Function to apply all methods
configure_all_methods() {
    echo -e "${BLUE}Applying all GDM configuration methods...${NC}"
    echo
    configure_gdm_dconf
    echo
    configure_gdm_localectl
    echo
    configure_gdm_user
    echo
    configure_gdm_keyboard
    echo
    configure_gdm_greeter
    echo -e "${GREEN}✓ All methods completed${NC}"
}

# Main function
main() {
    # Check if running as root
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "${RED}This script must be run with sudo privileges${NC}"
        echo -e "${YELLOW}Run: sudo $0${NC}"
        exit 1
    fi
    
    # Check if GDM is installed
    if ! systemctl list-units --full -all | grep -Fq "gdm"; then
        echo -e "${RED}GDM not detected on this system${NC}"
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "Enter your choice (0-6): " choice
        echo
        
        case $choice in
            1)
                configure_gdm_dconf
                ;;
            2)
                configure_gdm_localectl
                ;;
            3)
                configure_gdm_user
                ;;
            4)
                configure_gdm_keyboard
                ;;
            5)
                configure_gdm_greeter
                ;;
            6)
                configure_all_methods
                ;;
            0)
                echo -e "${YELLOW}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please enter 0-6.${NC}"
                continue
                ;;
        esac
        
        echo
        echo -e "${CYAN}Restarting GDM service...${NC}"
        systemctl restart gdm 2>/dev/null || {
            echo -e "${YELLOW}Could not restart GDM automatically. Please restart manually or reboot.${NC}"
        }
        
        echo
        read -p "Press Enter to continue or Ctrl+C to exit..."
        echo
    done
}

# Run main function with arguments
main "$@"