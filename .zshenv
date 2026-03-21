# .zshenv — single entry point for all zsh startup
#
# This file runs on every zsh invocation (interactive, non-interactive, login, script).
# It sources files from Personal/{zsh,bash}_startup and ~/{zsh,bash}_startup in
# alphabetical order. Files with .only_bash. in the name are skipped.
#
# Naming convention:
#   NN_NN_description.zsh                — zsh only
#   NN_NN_description.bash               — shared (sourced by both zsh and bash)
#   NN_NN_description.only_bash.bash     — bash only (skipped here)
#   NN_NN_description.if_login.zsh       — only in login shells
#   NN_NN_description.if_interactive.zsh — only in interactive shells
#
# Private/machine-specific config goes in ~/Personal/{zsh,bash}_startup/

for f in $(printf '%s\n' \
    "$HOME/Personal/bash_startup"/* \
    "$HOME/Personal/zsh_startup"/* \
    "$HOME/bash_startup"/* \
    "$HOME/zsh_startup"/* \
    2>/dev/null | sort); do
    [ -f "$f" ] || continue
    case "$f" in
        *.only_bash.*)        continue ;;
        *.if_login.zsh)       [[ -o login ]] || continue ;;
        *.if_interactive.zsh) [[ -o interactive ]] || continue ;;
    esac
    [[ -o interactive ]] && echo "[zsh] loading: $f"
    . "$f"
done
