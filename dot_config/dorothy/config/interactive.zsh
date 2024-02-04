
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


eval "$(mise activate zsh)"

export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

if is-wsl; then
# WSL-specific code
export BROWSER=/usr/bin/wslview
alias open="/usr/bin/wslview"

# for 1password ref https://developer.1password.com/docs/ssh/integrations/wsl/
alias ssh="ssh.exe"
alias ssh-add="ssh-add.exe"
git config --global core.sshCommand ssh.exe
fi

export PATH=/usr/bin:$PATH


if [ -S /var/run/docker.sock ]; then
    export DOCKER_HOST=unix:///var/run/docker.sock
    export DOCKER_HOST_PATH="/var/run/docker.sock"
elif [ -S /run/user/$UID/docker.sock ]; then
    export DOCKER_HOST=unix:///run/user/$UID/docker.sock
    export DOCKER_HOST_PATH=${DOCKER_HOST#unix://}
fi

export EDITOR="$(which code) --wait"
export SUDO_EDITOR=EDITOR

export PATH="$PATH:/snap/bin"
export PATH="$PATH:$HOME/.cargo/bin"

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac



PATH="$HOME/.local/share/mise/shims:$PATH"

# run here since it checks for the existence cmd
if  mise list zoxide &> /dev/null; then
    BIN=$(mise which zoxide)
    eval "$($BIN init zsh)"
fi

if  mise list mcfly &> /dev/null; then
    BIN=$(mise which mcfly)
    eval "$($BIN init zsh)"
fi


if  mise list flutter &> /dev/null ; then
    export FLUTTER_ROOT="$(mise where flutter)"
fi

if command -v thefuck &> /dev/null; then
    eval $(thefuck --alias)
fi

# fix poetry keyring https://github.com/python-poetry/poetry/issues/1917
export PYTHON_KEYRING_BACKEND=keyring.backends.fail.Keyring

if command -v starship &> /dev/null
then
    eval "$(starship init zsh)"
fi


export DOROTHY_THEME='starship'

