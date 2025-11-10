#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure the script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${RED}Please run as root (use sudo).${NC}"
    exit 1
fi

# Check for required tools
echo -e "${BLUE}Checking required tools...${NC}"
if ! command -v xsltproc >/dev/null 2>&1; then
    echo -e "${YELLOW}xsltproc not found. Installing...${NC}"
    apt-get update && apt-get install -y xsltproc
fi

# Function to install Manoonchai layout
install_manoonchai() {
    echo -e "${BLUE}Installing Manoonchai keyboard layout...${NC}"
    
    # Find Manoonchai_xkb file
    MANOONCHAI_FILE=""
    if [[ -f "${SCRIPT_DIR}/../layouts/manoonchai/Manoonchai_xkb" ]]; then
        MANOONCHAI_FILE="${SCRIPT_DIR}/../layouts/manoonchai/Manoonchai_xkb"
    elif [[ -f "${SCRIPT_DIR}/Manoonchai_xkb" ]]; then
        MANOONCHAI_FILE="${SCRIPT_DIR}/Manoonchai_xkb"
    elif [[ -f "${SCRIPT_DIR}/manoonchai/Manoonchai_xkb" ]]; then
        MANOONCHAI_FILE="${SCRIPT_DIR}/manoonchai/Manoonchai_xkb"
    else
        echo -e "${YELLOW}Manoonchai_xkb file not found. Please provide the path:${NC}"
        read -r MANOONCHAI_FILE
        if [[ ! -f "$MANOONCHAI_FILE" ]]; then
            echo -e "${RED}File not found: $MANOONCHAI_FILE${NC}"
            return 1
        fi
    fi
    
    # Apply patch to change ThaiMnc to manoonchai if needed
    if grep -q 'xkb_symbols "ThaiMnc"' "$MANOONCHAI_FILE"; then
        echo -e "${YELLOW}Applying patch to use lowercase 'manoonchai' instead of 'ThaiMnc'...${NC}"
        
        # Create backup
        if [[ ! -f "${MANOONCHAI_FILE}.original" ]]; then
            cp "$MANOONCHAI_FILE" "${MANOONCHAI_FILE}.original"
        fi
        
        # Apply the change
        sed -i 's/xkb_symbols "ThaiMnc"/xkb_symbols "manoonchai"/' "$MANOONCHAI_FILE"
        echo -e "${GREEN}✓ Patch applied: ThaiMnc → manoonchai${NC}"
        
        # Clean up old ThaiMnc entries if they exist
        if grep -q "ThaiMnc" /usr/share/X11/xkb/symbols/th 2>/dev/null; then
            echo -e "${YELLOW}Cleaning up old ThaiMnc entries...${NC}"
            # Remove the old ThaiMnc section
            sed -i '/xkb_symbols "ThaiMnc"/,/^xkb_symbols\|^$/{ /^xkb_symbols "ThaiMnc"/d; /^$/!d; }' /usr/share/X11/xkb/symbols/th
        fi
    fi
    
    # Run the Manoonchai installation script
    if [[ -f "${SCRIPT_DIR}/../layouts/manoonchai/executable_installmanoonchai.sh" ]]; then
        echo -e "${GREEN}Running Manoonchai installation script...${NC}"
        bash "${SCRIPT_DIR}/../layouts/manoonchai/executable_installmanoonchai.sh" "$MANOONCHAI_FILE"
    else
        echo -e "${RED}executable_installmanoonchai.sh not found in ${SCRIPT_DIR}/../layouts/manoonchai/${NC}"
        return 1
    fi
}

# Function to install Graphite layout
install_graphite() {
    echo -e "${BLUE}Installing Graphite keyboard layout...${NC}"
    
    # Check if graphite-layout/linux directory exists
    GRAPHITE_DIR="${SCRIPT_DIR}/../layouts/graphite/graphite-layout/linux"
    if [[ ! -d "$GRAPHITE_DIR" ]]; then
        echo -e "${RED}Graphite layout directory not found: $GRAPHITE_DIR${NC}"
        return 1
    fi
    
    # Run the Graphite installation script
    if [[ -f "${GRAPHITE_DIR}/install.sh" ]]; then
        echo -e "${GREEN}Running Graphite installation script...${NC}"
        cd "$GRAPHITE_DIR"
        bash install.sh
        cd "$SCRIPT_DIR"
    else
        echo -e "${RED}install.sh not found in $GRAPHITE_DIR${NC}"
        return 1
    fi
}

# Function to verify installations
verify_installations() {
    echo -e "${BLUE}Verifying installations...${NC}"
    
    # Check for Manoonchai in Thai variants
    if grep -q "manoonchai" /usr/share/X11/xkb/symbols/th 2>/dev/null; then
        echo -e "${GREEN}✓ Manoonchai layout found${NC}"
    else
        echo -e "${YELLOW}⚠ Manoonchai layout not found in symbols${NC}"
    fi
    
    # Check for Graphite in US variants
    if grep -q "graphite" /usr/share/X11/xkb/symbols/us 2>/dev/null; then
        echo -e "${GREEN}✓ Graphite layout found${NC}"
    else
        echo -e "${YELLOW}⚠ Graphite layout not found in symbols${NC}"
    fi
    
    # Check evdev.xml for both layouts
    if grep -q "manoonchai" /usr/share/X11/xkb/rules/evdev.xml 2>/dev/null; then
        echo -e "${GREEN}✓ Manoonchai registered in evdev.xml${NC}"
    else
        echo -e "${YELLOW}⚠ Manoonchai not registered in evdev.xml${NC}"
    fi
    
    if grep -q "graphite" /usr/share/X11/xkb/rules/evdev.xml 2>/dev/null; then
        echo -e "${GREEN}✓ Graphite registered in evdev.xml${NC}"
    else
        echo -e "${YELLOW}⚠ Graphite not registered in evdev.xml${NC}"
    fi
}

# Main installation flow
main() {
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}  Keyboard Layout Installation Script${NC}"
    echo -e "${GREEN}  Installing Graphite and Manoonchai layouts${NC}"
    echo -e "${GREEN}=================================================${NC}"
    echo
    
    # Install Manoonchai
    if install_manoonchai; then
        echo -e "${GREEN}✓ Manoonchai installation completed${NC}"
    else
        echo -e "${RED}✗ Manoonchai installation failed${NC}"
    fi
    
    echo
    
    # Install Graphite
    if install_graphite; then
        echo -e "${GREEN}✓ Graphite installation completed${NC}"
    else
        echo -e "${RED}✗ Graphite installation failed${NC}"
    fi
    
    echo
    
    # Verify installations
    verify_installations
    
    echo
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}=================================================${NC}"
    echo
    echo -e "${YELLOW}Installed layouts:${NC}"
    echo "  • US English - Graphite (us+graphite)"
    echo "  • Thai - Manoonchai (th+manoonchai)"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Run the configuration script to set up GNOME input sources:"
    echo -e "${GREEN}     ./configure-gnome-input.sh${NC}"
    echo "  2. Log out and log back in (or reboot) for changes to take effect"
    echo
}

# Run main function
main