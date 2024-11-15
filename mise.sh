curl https://mise.run | sh
echo "eval \"\$(/home/ben/.local/bin/mise activate bash)\"" >> ~/.bashrc
sudo apt install unzip
mise settings set experimental true
sudo  apt install python3.12-venv
mise use -g pipx
mise use -g pipx:pgcli

mise use -g cargo:cargo-binstall
mise use -g cargo:zellij
