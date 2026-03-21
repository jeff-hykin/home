# Add deno completions to search path
if [[ ":$FPATH:" != *":$HOME/completions:"* ]]; then
    export FPATH="$HOME/completions:$FPATH"
fi
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then
    export FPATH="$HOME/.zsh/completions:$FPATH"
fi
