#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  Fixing Manoonchai Duplicate Entries${NC}"
echo -e "${GREEN}=================================================${NC}"
echo

# Backup function
backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.$(date +%Y%m%d-%H%M%S).backup"
        cp "$file" "$backup"
        echo -e "${BLUE}Backed up: $(basename $file)${NC}"
    fi
}

# 1. Remove duplicate ThaiMnc entries from XML files
echo -e "${YELLOW}Removing duplicate ThaiMnc entries from XML files...${NC}"

for xml_file in /usr/share/X11/xkb/rules/evdev.xml /usr/share/X11/xkb/rules/base.xml; do
    if [[ -f "$xml_file" ]]; then
        backup_file "$xml_file"
        
        # Check if ThaiMnc exists
        if grep -q "<name>ThaiMnc</name>" "$xml_file"; then
            echo -e "${BLUE}Removing ThaiMnc variant from $(basename $xml_file)...${NC}"
            
            # Remove the entire variant block containing ThaiMnc
            # This uses a more precise method to remove the complete variant block
            awk '
                /<variant>/ { 
                    variant_block = $0; 
                    in_variant = 1; 
                    next 
                }
                in_variant {
                    variant_block = variant_block "\n" $0
                    if (/<name>ThaiMnc<\/name>/) {
                        has_thaimnc = 1
                    }
                    if (/<\/variant>/) {
                        if (!has_thaimnc) {
                            print variant_block
                        } else {
                            print "        <!-- Removed ThaiMnc variant -->"
                        }
                        in_variant = 0
                        has_thaimnc = 0
                        variant_block = ""
                        next
                    }
                    next
                }
                { print }
            ' "$xml_file" > "${xml_file}.tmp"
            
            mv "${xml_file}.tmp" "$xml_file"
            echo -e "${GREEN}✓ Removed ThaiMnc from $(basename $xml_file)${NC}"
        else
            echo -e "${GREEN}✓ No ThaiMnc found in $(basename $xml_file)${NC}"
        fi
    fi
done

# 2. Clean up LST files
echo -e "${YELLOW}Cleaning up LST files...${NC}"

for lst_file in /usr/share/X11/xkb/rules/evdev.lst /usr/share/X11/xkb/rules/base.lst; do
    if [[ -f "$lst_file" ]]; then
        backup_file "$lst_file"
        
        if grep -q "ThaiMnc" "$lst_file"; then
            echo -e "${BLUE}Removing ThaiMnc from $(basename $lst_file)...${NC}"
            sed -i '/ThaiMnc/d' "$lst_file"
            echo -e "${GREEN}✓ Removed ThaiMnc from $(basename $lst_file)${NC}"
        else
            echo -e "${GREEN}✓ No ThaiMnc found in $(basename $lst_file)${NC}"
        fi
    fi
done

# 3. Check and clean symbols file
echo -e "${YELLOW}Checking symbols file for duplicates...${NC}"

SYMBOLS_FILE="/usr/share/X11/xkb/symbols/th"
if [[ -f "$SYMBOLS_FILE" ]]; then
    backup_file "$SYMBOLS_FILE"
    
    # Count occurrences of manoonchai symbol definitions
    count_manoonchai=$(grep -c 'xkb_symbols "manoonchai"' "$SYMBOLS_FILE" || true)
    count_thaimnc=$(grep -c 'xkb_symbols "ThaiMnc"' "$SYMBOLS_FILE" || true)
    
    echo "Found $count_manoonchai 'manoonchai' definitions"
    echo "Found $count_thaimnc 'ThaiMnc' definitions"
    
    if [[ $count_thaimnc -gt 0 ]]; then
        echo -e "${BLUE}Removing ThaiMnc definitions from symbols file...${NC}"
        
        # Remove ThaiMnc symbol blocks
        awk '
            /xkb_symbols "ThaiMnc"/ {
                in_thaimnc = 1
                print "// Removed ThaiMnc block"
                next
            }
            in_thaimnc && /^};/ {
                in_thaimnc = 0
                next
            }
            in_thaimnc {
                next
            }
            { print }
        ' "$SYMBOLS_FILE" > "${SYMBOLS_FILE}.tmp"
        
        mv "${SYMBOLS_FILE}.tmp" "$SYMBOLS_FILE"
        echo -e "${GREEN}✓ Removed ThaiMnc definitions${NC}"
    fi
    
    # If there are duplicate manoonchai entries, keep only one
    if [[ $count_manoonchai -gt 1 ]]; then
        echo -e "${BLUE}Removing duplicate manoonchai definitions...${NC}"
        
        # Keep only the first manoonchai definition
        awk '
            /xkb_symbols "manoonchai"/ {
                if (seen_manoonchai) {
                    in_duplicate = 1
                    print "// Removed duplicate manoonchai block"
                    next
                }
                seen_manoonchai = 1
            }
            in_duplicate && /^};/ {
                in_duplicate = 0
                next
            }
            in_duplicate {
                next
            }
            { print }
        ' "$SYMBOLS_FILE" > "${SYMBOLS_FILE}.tmp"
        
        mv "${SYMBOLS_FILE}.tmp" "$SYMBOLS_FILE"
        echo -e "${GREEN}✓ Removed duplicate manoonchai definitions${NC}"
    fi
fi

# 4. Update dconf database
echo -e "${YELLOW}Updating dconf database...${NC}"
dconf update
echo -e "${GREEN}✓ dconf database updated${NC}"

# 5. Reconfigure xkb-data if on Debian-based system
if [[ -f /etc/debian_version ]]; then
    echo -e "${YELLOW}Reconfiguring xkb-data...${NC}"
    dpkg-reconfigure -phigh xkb-data 2>/dev/null || true
    echo -e "${GREEN}✓ xkb-data reconfigured${NC}"
fi

# 6. Clear XKB cache
echo -e "${YELLOW}Clearing XKB cache...${NC}"
rm -rf /var/lib/xkb/*.xkm 2>/dev/null || true
echo -e "${GREEN}✓ XKB cache cleared${NC}"

# Final verification
echo
echo -e "${BLUE}Verification:${NC}"

# Check XML files
for xml_file in /usr/share/X11/xkb/rules/evdev.xml /usr/share/X11/xkb/rules/base.xml; do
    if [[ -f "$xml_file" ]]; then
        count=$(grep -c "Thai.*Manoonchai" "$xml_file" || true)
        echo "$(basename $xml_file): $count Manoonchai entry/entries"
    fi
done

# Check symbols file
if [[ -f "$SYMBOLS_FILE" ]]; then
    count=$(grep -c 'xkb_symbols "manoonchai"' "$SYMBOLS_FILE" || true)
    echo "symbols/th: $count manoonchai definition(s)"
fi

echo
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  Cleanup Complete!${NC}"
echo -e "${GREEN}=================================================${NC}"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Log out and log back in"
echo "  2. Or restart your session: systemctl restart gdm"
echo "  3. Check Settings → Keyboard → Input Sources"
echo
echo -e "${GREEN}The Manoonchai layout should now display correctly as 'Thai (Manoonchai v1.0)'${NC}"