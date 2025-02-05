alias c='cd "$(xplr --print-pwd-as-result)"'

x () {
    if [ -z "$1" ]
    then
        cd "$(xplr --print-pwd-as-result)"
    else
        local current_dir="$PWD"
        cd "$1"
        xplr --print-pwd-as-result
        cd "$current_dir"
    fi
}