__path_to_fd="$(which fd)"
fd () {
    # for each argument (in a argument-might-have-spaces friendly way)
    for arg in "$@"; do
        # FIXME: this is imperfect because these could appear after a "--"
        if [ "--exact-depth" = "$arg" ] || [ "--max-depth" = "$arg" ] || [ "--min-depth" = "$arg" ] || [ "-d" = "$arg" ]
        then
            return "$__path_to_fd" --hidden --no-ignore -p "$@"
        fi
    done
    
    # poor mans breath-first-search since fd doesn't support it yet 
    # https://github.com/sharkdp/fd/issues/734
    index=-1 ; while [ "$index" -lt 256 ]; do
        index=$((index+1))
        "$__path_to_fd" --exact-depth $index --hidden --no-ignore -p "$@"
    done
}
