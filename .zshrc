# .zshrc — single place for all zsh startup logic
#
# This file is sourced in two ways:
#   1. Automatically by zsh for interactive shells (runs after /etc/zshrc,
#      so system defaults like PS1 won't clobber our prompt)
#   2. Manually from .zshenv for non-interactive shells (since zsh skips
#      .zshrc for those, but we still want PATH/env vars set up)
#
# It sources files from ~/Personal/{zsh,bash}_startup and ~/{zsh,bash}_startup,
# sorted alphabetically by basename so files from both dirs interleave by number.
#
# Naming convention:
#   NN_NN_description.zsh                — zsh only
#   NN_NN_description.bash               — shared (sourced by both zsh and bash)
#   NN_NN_description.only_bash.bash     — bash only (skipped here)
#   NN_NN_description.if_login.zsh       — only in login shells
#   NN_NN_description.if_interactive.zsh — only in interactive shells
#
# Private/machine-specific config goes in ~/Personal/{zsh,bash}_startup/

# Guard against being sourced twice (e.g. interactive shell: .zshenv would
# skip us, then zsh sources us automatically — but just in case)
[[ -n "$__zshrc_loaded" ]] && return
__zshrc_loaded=1

# Collect all files, then sort by basename so bash_startup and zsh_startup interleave
for f in $(
    for __f in \
        "$HOME/Personal/bash_startup"/*(N) \
        "$HOME/Personal/zsh_startup"/*(N) \
        "$HOME/bash_startup"/*(N) \
        "$HOME/zsh_startup"/*(N) \
    ; do
        [ -f "$__f" ] && echo "${__f##*/}	$__f"
    done | sort -t'	' -k1,1 | cut -f2
); do
    case "$f" in
        *.only_bash.*)         continue ;;
        *.if_login.zsh)        [[ -o login ]] || continue ;;
        *.if_interactive.zsh)  [[ -o interactive ]] || continue ;;
        *.if_interactive.bash) [[ -o interactive ]] || continue ;;
    esac
    [[ -o interactive ]] && echo "[zsh] loading: $f"
    . "$f"
done
unset __f f
