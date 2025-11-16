#!/usr/bin/env bash
#
# Enable System-wide Emoji Support on Ubuntu
# Source: https://gist.github.com/arafathusayn/3d384adfbbdfe0b6a12868e9046e9a23
#

set -euo pipefail

echo "Setting up emoji support on Ubuntu..."

# Install Noto Color Emoji font
echo "Installing fonts-noto-color-emoji..."
sudo apt install -y fonts-noto-color-emoji

# Create fontconfig directory
mkdir -p ~/.config/fontconfig/conf.d/

# Create emoji font configuration
echo "Creating font configuration..."
cat > ~/.config/fontconfig/conf.d/01-emoji.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF

# Refresh font cache
echo "Refreshing font cache..."
sudo fc-cache -f -v

echo ""
echo "✅ Emoji support setup completed!"
echo ""
echo "📝 Next steps:"
echo "  1. Restart your applications to apply changes"
echo "  2. Test emoji rendering at: https://getemoji.com/"
echo ""
echo "💡 This method works on Ubuntu, Zorin OS, Arch Linux, and other Debian-based distributions"
