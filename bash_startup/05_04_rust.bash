# check if file exists
if [ -f "$HOME/.cargo/env" ]
then
    . "$HOME/.cargo/env"
    export PATH="$PATH:$HOME/.cargo/bin"
fi