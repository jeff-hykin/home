__path_to_fd="$(which fd)"
fd () {
    "$__path_to_fd" --hidden --no-ignore "$@"
}