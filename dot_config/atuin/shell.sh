# -- Atuin daemon management
# On ZFS filesystems, we need to use Atuin's daemon mode to avoid the SQLite/ZFS 
# performance bug (https://github.com/atuinsh/atuin/issues/952).
# If the Atuin daemon process is running, we point to a ZFS-specific
# config that has daemon=true enabled. This ensures that all Atuin commands
# communicate with the running daemon rather than attempting direct database access.
# The setup-atuin-daemon.sh script should be run on ZFS systems to create and 
# start the systemd service for the daemon.
if pgrep -f "atuin daemon" > /dev/null; then
  export ATUIN_CONFIG_DIR="$HOME/.config/atuin/zfs"
fi

# Initialize Atuin
eval "$(atuin init bash)" # or zsh