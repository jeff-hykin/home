




# if running a command like scp (non-interative) return to prevent errors
[ -z "$PS1" ] && return

# 
# shell-agnostic setup
# 
export SHELL_STANDARD_ENV_SOURCE="$HOME/Terminal/"
export SHELL_STANDARD_ENV_COMMANDS="$HOME/Commands/"
export SHELL_STANDARD_ENV_VERSION_MAJOR="0"
export SHELL_STANDARD_ENV_VERSION_MINOR="0"
export SHELL_STANDARD_ENV_VERSION_PATCH="1"
export SHELL_STANDARD_ENV_PROFILE_WAS_INITILIZED="true"

#
# add commands to path
#
mkdir -p "$SHELL_STANDARD_ENV_COMMANDS"
export PATH="$PATH:$SHELL_STANDARD_ENV_COMMANDS"
# make all commands executable
# (this loop is so stupidly complicated because of many inherent-to-shell reasons, for example: https://stackoverflow.com/questions/13726764/while-loop-subshell-dilemma-in-bash
for_each_item_in="$SHELL_STANDARD_ENV_COMMANDS"; [ -z "$__NESTED_WHILE_COUNTER" ] && __NESTED_WHILE_COUNTER=0;__NESTED_WHILE_COUNTER="$((__NESTED_WHILE_COUNTER + 1))"; trap 'rm -rf "$__temp_var__temp_folder"' EXIT; __temp_var__temp_folder="$(mktemp -d)"; mkfifo "$__temp_var__temp_folder/pipe_for_while_$__NESTED_WHILE_COUNTER"; (find "$for_each_item_in" -maxdepth 1 ! -path "$for_each_item_in" -print0 2>/dev/null | sort -z > "$__temp_var__temp_folder/pipe_for_while_$__NESTED_WHILE_COUNTER" &); while read -d $'\0' each
do
    # check if file exists
    if [ -f "$each" ]
    then
        chmod u+x "$each"
    fi
done < "$__temp_var__temp_folder/pipe_for_while_$__NESTED_WHILE_COUNTER";__NESTED_WHILE_COUNTER="$((__NESTED_WHILE_COUNTER - 1))"

# 
# Pick the shell
# 

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
