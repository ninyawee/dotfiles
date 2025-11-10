curl -fsSL https://get.docker.com | sh

# for Ubuntu 22
export XDG_RUNTIME_DIR=/run/user/$(id -u)
sudo apt-get install -y uidmap

dockerd-rootless-setuptool.sh install

