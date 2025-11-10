#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  Manoonchai Layout Patch Application${NC}"
echo -e "${GREEN}=================================================${NC}"
echo

# Check if patch file exists
if [[ ! -f "${SCRIPT_DIR}/manoonchai_lowercase.patch" ]]; then
    echo -e "${RED}Patch file not found: manoonchai_lowercase.patch${NC}"
    exit 1
fi

# Check if Manoonchai_xkb exists
if [[ ! -f "${SCRIPT_DIR}/Manoonchai_xkb" ]]; then
    echo -e "${RED}Manoonchai_xkb file not found${NC}"
    exit 1
fi

# Create backup
echo -e "${BLUE}Creating backup of Manoonchai_xkb...${NC}"
cp "${SCRIPT_DIR}/Manoonchai_xkb" "${SCRIPT_DIR}/Manoonchai_xkb.backup"
echo -e "${GREEN}✓ Backup created: Manoonchai_xkb.backup${NC}"

# Apply patch
echo -e "${BLUE}Applying patch to change ThaiMnc to manoonchai...${NC}"
patch "${SCRIPT_DIR}/Manoonchai_xkb" < "${SCRIPT_DIR}/manoonchai_lowercase.patch"
echo -e "${GREEN}✓ Patch applied successfully${NC}"

echo
echo -e "${YELLOW}Patch applied! The layout ID has been changed from 'ThaiMnc' to 'manoonchai'${NC}"
echo

# Ask if user wants to reinstall
read -p "Do you want to reinstall the Manoonchai layout now? (requires sudo) [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Cleaning up old ThaiMnc entries...${NC}"
    
    # Check if we need sudo
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "${YELLOW}This operation requires root privileges. Please run with sudo.${NC}"
        echo -e "${GREEN}Run: sudo $0${NC}"
        exit 1
    fi
    
    # Remove old ThaiMnc entries from symbols file
    if grep -q "ThaiMnc" /usr/share/X11/xkb/symbols/th 2>/dev/null; then
        echo -e "${BLUE}Removing old ThaiMnc entries from symbols file...${NC}"
        # Create a backup first
        cp /usr/share/X11/xkb/symbols/th /usr/share/X11/xkb/symbols/th.pre-patch.backup
        # Remove the old ThaiMnc section (from xkb_symbols "ThaiMnc" to the next xkb_symbols or end of file)
        sed -i '/xkb_symbols "ThaiMnc"/,/^xkb_symbols\|^$/{ /^xkb_symbols "ThaiMnc"/d; /^$/!d; }' /usr/share/X11/xkb/symbols/th
        echo -e "${GREEN}✓ Old entries removed${NC}"
    fi
    
    # Remove old ThaiMnc entries from XML files
    for f in /usr/share/X11/xkb/rules/evdev.xml /usr/share/X11/xkb/rules/base.xml; do
        if grep -q "ThaiMnc" "$f" 2>/dev/null; then
            echo -e "${BLUE}Removing old ThaiMnc entries from $(basename $f)...${NC}"
            cp "$f" "$f.pre-patch.backup"
            # Remove the variant block containing ThaiMnc
            sed -i '/<variant>/,/<\/variant>/{/<name>ThaiMnc<\/name>/d;}' "$f"
            # Clean up empty variant blocks
            sed -i '/<variant>/{N;N;N;/<variant>\s*<\/variant>/d;}' "$f"
            echo -e "${GREEN}✓ Cleaned $(basename $f)${NC}"
        fi
    done
    
    # Remove old ThaiMnc entries from LST files
    for f in /usr/share/X11/xkb/rules/evdev.lst /usr/share/X11/xkb/rules/base.lst; do
        if grep -q "ThaiMnc" "$f" 2>/dev/null; then
            echo -e "${BLUE}Removing old ThaiMnc entries from $(basename $f)...${NC}"
            cp "$f" "$f.pre-patch.backup"
            sed -i '/ThaiMnc/d' "$f"
            echo -e "${GREEN}✓ Cleaned $(basename $f)${NC}"
        fi
    done
    
    echo
    echo -e "${BLUE}Running installation script with patched file...${NC}"
    
    # Run the installation script
    if [[ -f "${SCRIPT_DIR}/install_keyboard_layouts.sh" ]]; then
        bash "${SCRIPT_DIR}/install_keyboard_layouts.sh"
    elif [[ -f "${SCRIPT_DIR}/installmanoonchai.sh" ]]; then
        bash "${SCRIPT_DIR}/installmanoonchai.sh" "${SCRIPT_DIR}/Manoonchai_xkb"
    else
        echo -e "${RED}Installation script not found${NC}"
        echo -e "${YELLOW}Please manually run the installation with the patched Manoonchai_xkb file${NC}"
    fi
    
    echo
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}  Patch and Installation Complete!${NC}"
    echo -e "${GREEN}=================================================${NC}"
    echo
    echo -e "${YELLOW}The Manoonchai layout is now available as 'th+manoonchai'${NC}"
    echo -e "${YELLOW}Run ./configure_gnome_input.sh to set up your input sources${NC}"
else
    echo -e "${YELLOW}Patch applied but not installed.${NC}"
    echo -e "${YELLOW}To install, run: sudo ./install_keyboard_layouts.sh${NC}"
fi