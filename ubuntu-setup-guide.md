# Ubuntu Setup Guide

A comprehensive guide for setting up Ubuntu with development tools, fonts, and utilities.

## Table of Contents
- [Enable System-wide Emoji Support](#enable-system-wide-emoji-support)
- [Install Essential Build Tools](#install-essential-build-tools)
- [Install Cloudflared](#install-cloudflared)
- [Install DevToys](#install-devtoys)
- [Install Python Development Dependencies](#install-python-development-dependencies)

---

## Enable System-wide Emoji Support

Enable emoji rendering across Ubuntu systems.

### Steps

1. **Install the font package:**
   ```bash
   sudo apt install fonts-noto-color-emoji
   ```

2. **Create font configuration:**

   Create `~/.config/fontconfig/conf.d/01-emoji.conf` with the following content:
   ```xml
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
   ```

3. **Refresh the font cache:**
   ```bash
   sudo fc-cache -f -v
   ```

4. **Restart applications** to apply changes

### Verification
Test emoji rendering at: https://getemoji.com/

### Compatibility
This method works across:
- Ubuntu 24.04+
- Zorin OS
- Arch Linux
- Other Debian-based distributions

### Alternative Method
If the package version fails, manually download fonts from [Google Fonts](https://fonts.google.com/noto/specimen/Noto+Color+Emoji).

---

## Install Essential Build Tools

Install APT packages for development (Python, C/C++, etc.).

```bash
#!/usr/bin/env bash
set -euo pipefail

# Update package list
sudo apt-get update

# Install essential build tools and libraries
sudo apt-get install -y \
    build-essential \
    gdb \
    lcov \
    libbz2-dev \
    libffi-dev \
    libgdbm-compat-dev \
    libgdbm-dev \
    liblzma-dev \
    libncurses5-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libzstd-dev \
    lzma \
    lzma-dev \
    tk-dev \
    usbutils \
    uuid-dev \
    zlib1g-dev

echo "Build tools installation complete!"
```

---

## Install Cloudflared

Install Cloudflare Tunnel client for secure connections.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Installing cloudflared..."

# Add Cloudflare GPG key
echo "Adding Cloudflare GPG key..."
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add Cloudflare repository
echo "Adding Cloudflare repository..."
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Install cloudflared
echo "Installing cloudflared package..."
sudo apt-get update && sudo apt-get install -y cloudflared

echo "cloudflared installation completed!"
cloudflared --version
```

**Source:** [Cloudflare Package Repository](https://pkg.cloudflare.com/)

---

## Install DevToys

DevToys is an offline toolbox for developers (JSON formatter, base64 encoder/decoder, etc.).

```bash
#!/usr/bin/env bash
set -euo pipefail

# Determine architecture
ARCH="$(uname -m)"

if [[ "$ARCH" == "x86_64" ]]; then
    DEB_ARCH="amd64"
elif [[ "$ARCH" == "aarch64" ]]; then
    DEB_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Get latest release from GitHub
echo "Fetching latest DevToys release..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/DevToys-app/DevToys/releases/latest)
DEB_URL=$(echo "$LATEST_RELEASE" | grep -o "https://.*devtoys_linux_${DEB_ARCH}\.deb" | head -1)

if [[ -z "$DEB_URL" ]]; then
    echo "Could not find .deb package for architecture: $DEB_ARCH"
    echo "Please download manually from: https://devtoys.app/download"
    exit 1
fi

# Download and install
echo "Downloading DevToys..."
TEMP_DEB="$(mktemp -t devtoys.XXXXXX.deb)"
curl -L -o "$TEMP_DEB" "$DEB_URL"

echo "Installing DevToys..."
sudo dpkg -i "$TEMP_DEB" || sudo apt-get install -f -y
rm -f "$TEMP_DEB"

echo "DevToys installation completed!"
```

**Website:** [devtoys.app](https://devtoys.app/)

---

## Install Python Development Dependencies

Install dependencies for building Python from source (useful for pyenv, custom builds).

```bash
#!/usr/bin/env bash
set -euo pipefail

# Install Python build dependencies
sudo apt-get build-dep python3
sudo apt-get install -y pkg-config

# Install additional libraries
sudo apt-get install -y \
    build-essential \
    gdb \
    lcov \
    pkg-config \
    libbz2-dev \
    libffi-dev \
    libgdbm-dev \
    libgdbm-compat-dev \
    liblzma-dev \
    libncurses5-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    lzma \
    lzma-dev \
    tk-dev \
    uuid-dev \
    zlib1g-dev \
    libzstd-dev \
    inetutils-inetd

echo "Python development dependencies installed!"
```

**Source:** [Python Developer's Guide](https://devguide.python.org/getting-started/setup-building/index.html#install-dependencies)

**Note:** For Ubuntu 24.04 and newer.

---

## Quick Start Script

Run all installations at once (use with caution):

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Starting Ubuntu setup..."

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Emoji support
sudo apt install -y fonts-noto-color-emoji
mkdir -p ~/.config/fontconfig/conf.d/
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
sudo fc-cache -f -v

# Build tools
sudo apt-get install -y \
    build-essential gdb lcov libbz2-dev libffi-dev \
    libgdbm-compat-dev libgdbm-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev \
    libzstd-dev lzma lzma-dev tk-dev usbutils uuid-dev zlib1g-dev

echo "Ubuntu setup completed! Please restart your applications."
```

---

## Contributing

Feel free to suggest improvements or additional setup scripts!

## License

MIT
