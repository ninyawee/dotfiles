# [not recommend] Set Port for docker
# if ! grep -q '^net.ipv4.ip_unprivileged_port_start=80$' /etc/sysctl.conf; then
#   echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee -a /etc/sysctl.conf
# fi
sudo apt-get install -y dbus-user-session
sudo apt-get install -y uidmap
curl -fsSL https://get.docker.com -o get-docker.sh
# sudo sh ./get-docker.sh --dry-run
sudo sh ./get-docker.sh

dockerd-rootless-setuptool.sh install
## NOTES
# [INFO] Installed docker.service successfully.
# [INFO] To control docker.service, run: `systemctl --user (start|stop|restart) docker.service`
# [INFO] To run docker.service on system startup, run: `sudo loginctl enable-linger nam`

# [INFO] Creating CLI context "rootless"
# Successfully created context "rootless"
# [INFO] Using CLI context "rootless"
# Current context is now "rootless"

# [INFO] Make sure the following environment variable(s) are set (or add them to ~/.bashrc):
# export PATH=/usr/bin:$PATH

# [INFO] Some applications may require the following environment variable too:
# export DOCKER_HOST=unix:///run/user/1002/docker.sock
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# allow to use port 80
sudo setcap cap_net_bind_service=ep $(which rootlesskit)


# config daemon
systemctl --user start docker
systemctl --user enable docker

# prevent docker from being killed when logout
sudo loginctl enable-linger $(whoami)