#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Usage: sudo ./install-manoonchai.sh /path/to/Manoonchai_xkb
# Ensure the script is run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi

# Get layout definition file from first argument
LAYOUT_FILE="$1"
if [[ -z "$LAYOUT_FILE" || ! -f "$LAYOUT_FILE" ]]; then
  echo "Usage: $0 /path/to/Manoonchai_xkb"
  exit 1
fi

echo "Installing from layout file: $LAYOUT_FILE"

# Timestamp for backup filenames
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Backup existing XKB files with timestamp
cp /usr/share/X11/xkb/symbols/th "/usr/share/X11/xkb/symbols/th.$TIMESTAMP.bak"
cp /usr/share/X11/xkb/rules/evdev.xml "/usr/share/X11/xkb/rules/evdev.xml.$TIMESTAMP.bak"
cp /usr/share/X11/xkb/rules/base.xml "/usr/share/X11/xkb/rules/base.xml.$TIMESTAMP.bak"
cp /usr/share/X11/xkb/rules/evdev.lst "/usr/share/X11/xkb/rules/evdev.lst.$TIMESTAMP.bak"
cp /usr/share/X11/xkb/rules/base.lst "/usr/share/X11/xkb/rules/base.lst.$TIMESTAMP.bak"
echo "Backups created with timestamp $TIMESTAMP."

# Extract layout ID and description from the layout file
LAYOUT_ID=$(grep -Po 'xkb_symbols\s+"(\K[^"]+)' "$LAYOUT_FILE" | head -1)
DESCRIPTION=$(grep -Po 'name\[Group1\]\s*=\s*"\K[^"]+' "$LAYOUT_FILE" | head -1)

if [[ -z "$LAYOUT_ID" || -z "$DESCRIPTION" ]]; then
  echo "Failed to extract layout id or description from $LAYOUT_FILE."
  exit 1
fi

# Append layout to symbols/th if not already present
if ! grep -q "xkb_symbols \"$LAYOUT_ID\"" /usr/share/X11/xkb/symbols/th; then
  sed '1s/^\xEF\xBB\xBF//' "$LAYOUT_FILE" | tee -a /usr/share/X11/xkb/symbols/th > /dev/null
  echo "$LAYOUT_ID layout added to /usr/share/X11/xkb/symbols/th."
else
  echo "$LAYOUT_ID layout already exists in /usr/share/X11/xkb/symbols/th."
fi

# Add layout entry to XML rules files (evdev.xml and base.xml)
for f in /usr/share/X11/xkb/rules/evdev.xml /usr/share/X11/xkb/rules/base.xml; do
  if ! grep -q "<name>$LAYOUT_ID</name>" "$f"; then
    sed -i "/<name>th<\/name>/,/<\/variantList>/ {
        /<variantList>/a\\
        <variant>\\
          <configItem>\\
            <name>$LAYOUT_ID</name>\\
            <description>$DESCRIPTION</description>\\
          </configItem>\\
        </variant>
        }" "$f"
    echo "$LAYOUT_ID layout added to $f..."
  else
    echo "$LAYOUT_ID layout already exists in $f."
  fi
done

# Add layout entry to .lst rules files (evdev.lst and base.lst)
for f in /usr/share/X11/xkb/rules/evdev.lst /usr/share/X11/xkb/rules/base.lst; do
  if ! grep -q "$LAYOUT_ID" "$f"; then
    sed -i "/pat             th: Thai (Pattachote)/a\  $LAYOUT_ID         th: $DESCRIPTION" "$f"
    echo "$LAYOUT_ID layout added to $f."
  else
    echo "$LAYOUT_ID layout already exists in $f."
  fi
done

# Reconfigure xkb-data if running on a Debian-based system
if [ -f /etc/debian_version ]; then
  dpkg-reconfigure xkb-data && echo "Debian system detected, xkb-data reconfigured."
fi

# Final success message
echo -e "\033[41;37mMa\033[0m\033[47;31mno\033[0m\033[44;37mon\033[0m\033[47;31mch\033[0m\033[41;37mai\033[0m layout installed.
Select it under Thai layout or restart X session to apply the changes for sure :)."
