# .zshenv — single entry point for all zsh startup
#
# This file runs on every zsh invocation (interactive, non-interactive, login, script).
# It sources files from ~/Personal/zsh_startup then ~/zsh_startup in alphabetical order.
#
# Naming convention:
#   NN_NN_description.zsh                — always runs
#   NN_NN_description.bash               — shared with bash (symlinked from bash_startup)
#   NN_NN_description.if_login.zsh       — only in login shells
#   NN_NN_description.if_interactive.zsh — only in interactive shells
#
# Private/machine-specific config goes in ~/Personal/zsh_startup/

for f in $(printf '%s\n' "$HOME/Personal/zsh_startup"/* "$HOME/zsh_startup"/* 2>/dev/null | sort); do
    [ -f "$f" ] || continue
    case "$f" in
        *.if_login.zsh)       [[ -o login ]] || continue ;;
        *.if_interactive.zsh) [[ -o interactive ]] || continue ;;
    esac
    [[ -o interactive ]] && echo "[zsh] loading: $f"
    . "$f"
done
