sudo apt install universal-ctags libportaudio2 -y

pipx install aider-chat
pipx inject aider-chat setuptools

eval $(op signin)
OPENAI_API_KEY=$(op read "op://Personal/Openai/API Key")

touch ~/.aider.conf.yml
# Add OpenAI API Key
echo "openai-api-key: $OPENAI_API_KEY" >> ~/.aider.conf.yml
