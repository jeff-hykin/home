# .zshenv — runs on every zsh invocation (interactive, non-interactive, login, script)
#
# Zsh sources files in this order:
#   .zshenv  →  /etc/zprofile  →  .zprofile  →  /etc/zshrc  →  .zshrc
#
# For interactive shells, zsh runs .zshrc automatically (after /etc/zshrc),
# so we do nothing here — all startup logic lives in .zshrc.
#
# For non-interactive shells (scripts, subshells), zsh never runs .zshrc,
# so we source it manually to ensure PATH, env vars, etc. are available.

if [[ ! -o interactive ]]; then
    . "$HOME/.zshrc"
fi
