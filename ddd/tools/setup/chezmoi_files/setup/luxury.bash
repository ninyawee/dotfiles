#!/usr/bin/env bash

asdf plugin add tokei
asdf install tokei latest
asdf global tokei latest

# Starship.rs  

sudo apt update

# Initialize the list of packages
apt_packages=()

install_apt_package() {
    if [[ $1 == "COMMIT" ]]; then
        # Install all packages in the list
        sudo apt install -y "${apt_packages[@]}"
        # Reset the list
        apt_packages=()
    else
        # Add the package to the list
        apt_packages+=("$1")
        echo "current pending packages: ${apt_packages[@]}"
    fi
}




# Install CLI tools
install_apt_package htop
install_apt_package ncdu
install_apt_package ripgrep
install_apt_package httpie
install_apt_package micro

install_apt_package COMMIT
sudo snap install dvc --classic

brew install ripgrep

# for `pipx` completions
pipx install argcomplete

pipx install glances
pipx install litecli
pipx install pgcli
# --include-deps setuptools not working
# https://stackoverflow.com/questions/77247893/modulenotfounderror-no-module-named-distutils-in-python-3-12
mise install python@3.11
mise use python@3.11
pipx install --python $(mise which python) thefuck
# pipx inject thefuck setuptools
pipx upgrade-all

cargo binstall --no-confirm rm-improved xcp sd procs bottom topgrade broot tokei  zellij xh monolith git-delta  
# fails: kdash
cargo binstall --no-confirm --git https://github.com/sirwart/ripsecrets ripsecrets 

brew install nushell
brew install flyctl
brew install tealdeer
tldr --update
