#!/usr/bin/env bash
# do not use `export` keyword in this file:
# shellcheck disable=SC2034

# APK
# Used by `setup-linux`
# APK_INSTALL=()

# Apt / apt-get
# Used by `setup-linux`
# APT_UNINSTALL=()
APT_INSTALL=(
	gdb
	lcov
	libbz2-dev
	libffi-dev
	libgdbm-compat-dev
	libgdbm-dev
	liblzma-dev
	# libmpdec-dev
	libncurses5-dev
	libreadline6-dev
	libsqlite3-dev
	libzstd-dev
	lzma
	lzma-dev
	tk-dev
	usbutils
	uuid-dev
	zlib1g-dev
)

# AUR / pamac / pacman / yay / paru / pakku / aurutils
# Used by `setup-linux`
# AUR_INSTALL=()

# Flatpak
# Used by `setup-linux`
# FLATPAK_INSTALL=()

# RPM / dnf / yum
# Used by `setup-linux`
# RPM_INSTALL=()

# Snap
# Used by `setup-linux`
# SNAP_INSTALL=()

# Zypper
# Used by `setup-linux`
# ZYPPER_INSTALL=()

# macOS App Store / mas / https://github.com/mas-cli/mas
# Used by `setup-mac-appstore`
# You can use `mas list` and `mas search` to find apps
# MAS_INSTALL=() # tuple array of id, label
# MAS_UPGRADE='no'

# Homebrew / brew / https://brew.sh
# Used by `setup-mac-brew`
# You can use `setup-mac-brew --configure` to configure some of these.
# HOMEBREW_UNTAPS=()
# HOMEBREW_TAPS=()
HOMEBREW_FORMULAS=(
	'jandedobbeleer/oh-my-posh/oh-my-posh'
)
# HOMEBREW_SLOW_FORMULAS=()
# HOMEBREW_CASKS=()
HOMEBREW_FONTS=(
	'font-cantarell'
	'font-cascadia-code'
	'font-fira-code'
	'font-fira-code-nerd-font'
	'font-fira-mono'
	'font-fira-mono-nerd-font'
	'font-hack' # many editors require this
	'font-hasklig'
	'font-ibm-plex' # many editors require this
	'font-inconsolata-go-nerd-font'
	'font-inter' # many apps require this
	'font-jetbrains-mono'
	'font-jetbrains-mono-nerd-font'
	'font-lato'
	'font-maven-pro'
	'font-monoid'
	'font-montserrat'
	'font-open-sans'
	'font-oxygen'
	'font-oxygen-mono'
	'font-roboto'
	'font-roboto-mono'
	'font-source-code-pro' # many editors require this
	'font-ubuntu'
)
# HOMEBREW_UNINSTALL=()        # for casks and formulas
# HOMEBREW_ENCODING_INSTALL='' # '', 'yes', 'no'

# Golang / go
# Used by `setup-go`
# GO_LINTING_INSTALL='' # '', 'yes', 'no'
# GO_INSTALL=()

# Node.js
# Used by `setup-node`
# NPM_INSTALL=()
# NODE_VERSIONS=()

# Python
# Used by `setup-python`
# PYTHON_INSTALL=()
# PIP_INSTALL=()
# PYTHON2_PIP_INSTALL=()
# PYTHON3_PIP_INSTALL=()
# PIPX_INSTALL=()

# Ruby
# Used by `setup-ruby`
# GEM_INSTALL=()

# Rust / Cargo / Crates.io
# Used by `setup-rust`
# CARGO_INSTALL=()

# Utilities to install, these are the [setup-util-*] scripts
# Used by `setup-utils`
# You can use `setup-utils --configure` to configure these.
SETUP_UTILS=(
	# bottom
	brew
	devel
	# dust
	# git
	# gum
	# lux
	# mas
	# micro
	# nano
	# nerd-fonts
	# netstat
	# procs
	# ripgrep
	# sd
	# shellcheck
	# shfmt
	# starship
	# tealdeer
	# tokei
	# tree
	# vim
	# zoxide
)

WINGET=(
	'Microsoft.WSL'
	'Canonical.Ubuntu'
	'Docker.DockerDesktop'
	'Kairos.DuetDisplay'
	'Git.Git'
	'Microsoft.PowerShell'
	'Tailscale.Tailscale'
	'Microsoft.Edge'
	'Valve.Steam'
	'AgileBits.1Password'
	'Anysphere.Cursor'
	'Notion.Notion'
	'AgileBits.1Password.CLI'
	'Discord.Discord'
	'Figma.Figma'
	'Obsidian.Obsidian'
	'Microsoft.VisualStudioCode'
	'Canonical.Ubuntu'
	'Microsoft.Teams'
	'Microsoft.DevHome'
	'Microsoft.WindowsTerminal'
	'TheBrowserCompany.Arc'
	'Microsoft.PowerToys'
	'Google.AndroidStudio'
	'GitHub.cli'
	'Zen-Team.Zen-Browser'
	'Python.Launcher'
	'astral-sh.uv'
	'HTTPie.HTTPie'
	'jdx.mise'
	'7zip.7zip'
	'WinFsp.WinFsp'
	'yt-dlp.yt-dlp'
	'VideoLAN.VLC'
	'OBSProject.OBSStudio'
	'Telegram.TelegramDesktop'
	'Microsoft.VisualStudio.2022.Community'
	'Gyan.FFmpeg'
	'Rclone.Rclone'
	'twpayne.chezmoi'
	'Postman.Postman'
	'OpenJS.NodeJS.LTS'
	'Microsoft.AzureCLI'
	'Microsoft.AzureStorageExplorer'
	'NSIS.NSIS'
	'Anaconda.Miniconda3'
	'Levitsky.FontBase'
	'DEVCOM.JetBrainsMonoNerdFont'
)
