__temp_var_zsh_highlighting_path="$SHELL_STANDARD_ENV_SOURCE/plugins/zsh-syntax-highlighting"
if [[ -d "$__temp_var_zsh_highlighting_path" ]]
then
    . "$__temp_var_zsh_highlighting_path/zsh-syntax-highlighting.zsh"
    export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$__temp_var_zsh_highlighting_path/highlighters"
fi
unset __temp_var_zsh_highlighting_path