




# if running a command like scp (non-interative) return to prevent errors
[ -z "$PS1" ] && return

# Pick the shell
export __profile_was_initilized="true"

# if zsh is available, run that instead of the normal shell
if command -v "zsh" &> /dev/null
then
    if [[ "$(basename "$SHELL")" != "zsh" ]]
    then
        export SHELL="$(which zsh)"
        
        # mac needs more than just the variable to be set
        if [[ "$OSTYPE" == "darwin"* ]] 
        then
            "$SHELL" "$@"
            exit
        fi
    fi
fi





