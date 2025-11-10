# done by `chezmoi apply` `private_dot_config/pypoetry/private_config.toml`

poetry config virtualenvs.in-project true

# https://github.com/python-poetry/poetry/issues/1917
export PYTHON_KEYRING_BACKEND=keyring.backends.fail.Keyring