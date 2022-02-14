# if zoxide exists
if [ -n "$(command -v "zoxide")" ]
then
    eval "$(zoxide init zsh)"
fi