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

# Function to verify keyboard layouts are installed
verify_layouts_installed() {
    echo -e "${BLUE}Verifying keyboard layouts are installed...${NC}"
    
    local all_found=true
    
    # Check for Graphite in US variants
    if grep -q "graphite" /usr/share/X11/xkb/symbols/us 2>/dev/null; then
        echo -e "${GREEN}✓ Graphite layout found${NC}"
    else
        echo -e "${RED}✗ Graphite layout not found - please run install-keyboard-layouts.sh first${NC}"
        all_found=false
    fi
    
    # Check for Manoonchai in Thai variants
    if grep -q "manoonchai" /usr/share/X11/xkb/symbols/th 2>/dev/null; then
        echo -e "${GREEN}✓ Manoonchai layout found${NC}"
    else
        echo -e "${RED}✗ Manoonchai layout not found - please run install-keyboard-layouts.sh first${NC}"
        all_found=false
    fi
    
    if [ "$all_found" = false ]; then
        echo -e "${RED}Please install the keyboard layouts first using: sudo ./install-keyboard-layouts.sh${NC}"
        exit 1
    fi
}

# Function to configure user input sources
configure_user_sources() {
    echo -e "${BLUE}Configuring GNOME input sources for current user...${NC}"
    
    # Check if gsettings is available
    if ! command -v gsettings >/dev/null 2>&1; then
        echo -e "${RED}gsettings not found. Install with: sudo apt-get install libglib2.0-bin${NC}"
        exit 1
    fi
    
    # Get current sources
    echo -e "${YELLOW}Current input sources:${NC}"
    gsettings get org.gnome.desktop.input-sources sources
    
    # Set new sources with US Graphite and Thai Manoonchai
    echo -e "${GREEN}Setting new input sources...${NC}"
    gsettings set org.gnome.desktop.input-sources sources "$GSETTINGS_VALUE"
    
    # Disable per-window input source (use global)
    gsettings set org.gnome.desktop.input-sources per-window false
    
    # Show input source in panel
    gsettings set org.gnome.desktop.input-sources show-all-sources true
    
    # Verify the change
    echo -e "${GREEN}New input sources:${NC}"
    gsettings get org.gnome.desktop.input-sources sources
    
    echo -e "${GREEN}✓ User input sources configured${NC}"
}

# Function to suggest GDM configuration
suggest_gdm_configuration() {
    echo -e "${BLUE}GDM Login Screen Configuration${NC}"
    echo -e "${YELLOW}To configure login screen input sources, run the separate GDM script:${NC}"
    echo -e "${GREEN}  sudo ./configure-gdm-input.sh${NC}"
    echo
}

# Function to show debugging information
show_debug_info() {
    echo -e "${CYAN}=== Debug Information ===${NC}"
    
    echo -e "${YELLOW}System locale and keyboard settings:${NC}"
    localectl status 2>/dev/null || echo "localectl not available"
    
    echo -e "${YELLOW}\nCurrent /etc/default/keyboard:${NC}"
    cat /etc/default/keyboard 2>/dev/null || echo "File not found"
    
    echo -e "${YELLOW}\nGDM dconf database status:${NC}"
    if [[ -d /etc/dconf/db/gdm.d ]]; then
        ls -la /etc/dconf/db/gdm.d/
    else
        echo "GDM dconf directory not found"
    fi
    
    echo -e "${YELLOW}\nCurrent X11 keyboard configuration:${NC}"
    setxkbmap -query 2>/dev/null || echo "setxkbmap not available"
    
    echo -e "${CYAN}=========================${NC}\n"
}

# Main function
main() {
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}  GNOME Input Source Configuration${NC}"
    echo -e "${GREEN}=================================================${NC}"
    echo
    
    # First verify layouts are installed
    verify_layouts_installed
    
    echo
    
    # Show debug info if requested
    if [[ "$1" == "--debug" ]]; then
        show_debug_info
    fi
    
    # Configure user sources (doesn't need sudo)
    configure_user_sources
    
    echo
    
    # Suggest GDM configuration
    suggest_gdm_configuration
    
    echo
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}  Configuration Complete!${NC}"
    echo -e "${GREEN}=================================================${NC}"
    echo
    echo -e "${YELLOW}Configured layouts:${NC}"
    echo "  • US English - Graphite"
    echo "  • Thai - Manoonchai"
    echo
    echo -e "${YELLOW}Keyboard shortcuts:${NC}"
    echo "  • Super+Space or Alt+Shift: Switch between input sources"
    echo "  • Configure more in Settings > Keyboard > Input Sources"
    echo
    echo -e "${YELLOW}Important notes:${NC}"
    echo "  • Reboot for full effect (especially for login screen)"
    echo "  • Run with --debug flag to see current configuration"
    echo "  • If login screen doesn't show layouts, try:"
    echo "    - Restarting GDM: sudo systemctl restart gdm"
    echo "    - Full reboot: sudo reboot"
    echo
}

# Run main function with arguments
main "$@"