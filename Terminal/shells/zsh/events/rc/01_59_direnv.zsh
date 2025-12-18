# if direnv exists
if [ -n "$(command -v "direnv")" ]; then
    echo "setting up direnv"
    eval "$(direnv hook zsh)"
fi