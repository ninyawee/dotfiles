#!/usr/bin/env bash
#
# Ubuntu Setup Script
# Installs essential development tools, emoji support, and utilities
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Ubuntu/Debian
check_os() {
    if ! command -v apt-get &> /dev/null; then
        log_error "This script requires apt-get (Ubuntu/Debian-based system)"
        exit 1
    fi
}

# Setup emoji support
setup_emoji() {
    log_info "Setting up emoji support..."

    sudo apt-get install -y fonts-noto-color-emoji

    # Create fontconfig directory
    mkdir -p ~/.config/fontconfig/conf.d/

    # Create emoji font configuration
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

    sudo fc-cache -f -v > /dev/null 2>&1
    log_success "Emoji support configured"
}

# Install essential build tools
install_build_tools() {
    log_info "Installing essential build tools..."

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

    log_success "Build tools installed"
}

# Install Python development dependencies
install_python_deps() {
    log_info "Installing Python development dependencies..."

    sudo apt-get build-dep -y python3 2>/dev/null || log_warning "Could not build-dep python3, continuing..."

    sudo apt-get install -y \
        pkg-config \
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

    log_success "Python dependencies installed"
}

# Install Cloudflared
install_cloudflared() {
    log_info "Installing cloudflared..."

    # Add Cloudflare GPG key
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

    # Add repository
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null

    # Install
    sudo apt-get update && sudo apt-get install -y cloudflared

    log_success "cloudflared installed: $(cloudflared --version)"
}

# Install DevToys
install_devtoys() {
    log_info "Installing DevToys..."

    ARCH="$(uname -m)"

    if [[ "$ARCH" == "x86_64" ]]; then
        DEB_ARCH="amd64"
    elif [[ "$ARCH" == "aarch64" ]]; then
        DEB_ARCH="arm64"
    else
        log_error "Unsupported architecture: $ARCH"
        return 1
    fi

    # Get latest release
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/DevToys-app/DevToys/releases/latest)
    DEB_URL=$(echo "$LATEST_RELEASE" | grep -o "https://.*devtoys_linux_${DEB_ARCH}\.deb" | head -1)

    if [[ -z "$DEB_URL" ]]; then
        log_error "Could not find .deb package for architecture: $DEB_ARCH"
        return 1
    fi

    # Download and install
    TEMP_DEB="$(mktemp -t devtoys.XXXXXX.deb)"
    curl -L -o "$TEMP_DEB" "$DEB_URL"
    sudo dpkg -i "$TEMP_DEB" || sudo apt-get install -f -y
    rm -f "$TEMP_DEB"

    log_success "DevToys installed"
}

# Main menu
show_menu() {
    echo ""
    echo "======================================"
    echo "   Ubuntu Setup Script"
    echo "======================================"
    echo ""
    echo "Select what to install:"
    echo ""
    echo "  1) Full setup (all options)"
    echo "  2) Emoji support only"
    echo "  3) Build tools only"
    echo "  4) Python dependencies only"
    echo "  5) Cloudflared only"
    echo "  6) DevToys only"
    echo "  7) Essential setup (emoji + build tools + python)"
    echo "  0) Exit"
    echo ""
    read -p "Enter your choice [0-7]: " choice
}

# Main execution
main() {
    check_os

    # Update package list
    log_info "Updating package lists..."
    sudo apt-get update

    if [[ $# -eq 0 ]]; then
        # Interactive mode
        show_menu

        case $choice in
            1)
                setup_emoji
                install_build_tools
                install_python_deps
                install_cloudflared
                install_devtoys
                ;;
            2)
                setup_emoji
                ;;
            3)
                install_build_tools
                ;;
            4)
                install_python_deps
                ;;
            5)
                install_cloudflared
                ;;
            6)
                install_devtoys
                ;;
            7)
                setup_emoji
                install_build_tools
                install_python_deps
                ;;
            0)
                log_info "Exiting..."
                exit 0
                ;;
            *)
                log_error "Invalid choice"
                exit 1
                ;;
        esac
    else
        # Non-interactive mode with flags
        while [[ $# -gt 0 ]]; do
            case $1 in
                --all)
                    setup_emoji
                    install_build_tools
                    install_python_deps
                    install_cloudflared
                    install_devtoys
                    shift
                    ;;
                --emoji)
                    setup_emoji
                    shift
                    ;;
                --build-tools)
                    install_build_tools
                    shift
                    ;;
                --python)
                    install_python_deps
                    shift
                    ;;
                --cloudflared)
                    install_cloudflared
                    shift
                    ;;
                --devtoys)
                    install_devtoys
                    shift
                    ;;
                --essential)
                    setup_emoji
                    install_build_tools
                    install_python_deps
                    shift
                    ;;
                -h|--help)
                    echo "Usage: $0 [OPTIONS]"
                    echo ""
                    echo "Options:"
                    echo "  --all           Install everything"
                    echo "  --essential     Install emoji + build tools + python"
                    echo "  --emoji         Setup emoji support"
                    echo "  --build-tools   Install build tools"
                    echo "  --python        Install Python dependencies"
                    echo "  --cloudflared   Install cloudflared"
                    echo "  --devtoys       Install DevToys"
                    echo "  -h, --help      Show this help message"
                    echo ""
                    echo "Examples:"
                    echo "  $0                        # Interactive mode"
                    echo "  $0 --all                  # Install everything"
                    echo "  $0 --emoji --python       # Install emoji and python deps"
                    exit 0
                    ;;
                *)
                    log_error "Unknown option: $1"
                    echo "Use --help for usage information"
                    exit 1
                    ;;
            esac
        done
    fi

    echo ""
    log_success "Setup completed!"
    echo ""
    log_info "Please restart your applications to apply changes"
    log_info "Test emoji support at: https://getemoji.com/"
}

main "$@"
