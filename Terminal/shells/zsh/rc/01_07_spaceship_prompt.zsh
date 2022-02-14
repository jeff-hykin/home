SPACESHIP_VENV_SYMBOL="🐍$(python -V 2>&1 | sed -E 's/Python//g' )"
SPACESHIP_VENV_PREFIX=""
SPACESHIP_VENV_GENERIC_NAMES="."
SPACESHIP_VENV_COLOR="green"
SPACESHIP_NODE_COLOR="yellow"

# not sure why this is needed on linux (related to installing spaceship through npm install -g spaceship-prompt)
fpath=($fpath "$HOME/.zfunctions")

# Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
prompt spaceship &>/dev/null

spaceship_prompt_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh"
if [[ -f "$spaceship_prompt_path" ]] 
then
    source "$spaceship_prompt_path"
fi