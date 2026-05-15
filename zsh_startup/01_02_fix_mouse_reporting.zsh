# Reset mouse reporting modes before each prompt.
# TUI apps (htop, less, etc.) sometimes enable mouse tracking and don't
# clean up on exit, causing scroll events to print as garbled escape sequences.
autoload -Uz add-zsh-hook
add-zsh-hook precmd _reset_mouse_reporting
_reset_mouse_reporting() {
    printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l'
}
