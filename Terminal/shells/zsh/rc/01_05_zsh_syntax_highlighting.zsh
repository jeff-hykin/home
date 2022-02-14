if [[ "$OSTYPE" == "darwin"* ]]; then
    source /usr/local/Cellar/zsh-syntax-highlighting/0.7.1/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters
fi

__temp_var_zsh_highlighting_path="$HOME/repos/zsh-syntax-highlighting"
if [[ -d "$__temp_var_zsh_highlighting_path" ]]
then
    source "$__temp_var_zsh_highlighting_path/zsh-syntax-highlighting.zsh"
    export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$__temp_var_zsh_highlighting_path/highlighters"
fi