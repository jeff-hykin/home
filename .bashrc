# always run the .profile first
if [[ "$SHELL_STANDARD_ENV_PROFILE_WAS_INITILIZED" != "true" ]]
then
    source "$HOME/.profile"
fi

# 
# debug check
# 
if [ "$SHELL_STANDARD_ENV_DEBUG" = "true" ]
then
    echo "[.bashrc] finished loading .profile"
fi

# 
# load sources
# 
# this loop is so stupidly complicated because of many inherent-to-shell reasons, for example: https://stackoverflow.com/questions/13726764/while-loop-subshell-dilemma-in-bash
for_each_item_in="$SHELL_STANDARD_ENV_SOURCE/shells/bash/events/rc"
[ -z "$__NESTED_WHILE_COUNTER" ] && __NESTED_WHILE_COUNTER=0;__NESTED_WHILE_COUNTER="$((__NESTED_WHILE_COUNTER + 1))"; trap 'rm -rf "$__temp_var__temp_folder"' EXIT; __temp_var__temp_folder="$(mktemp -d)"; mkfifo "$__temp_var__temp_folder/pipe_for_while_$__NESTED_WHILE_COUNTER"; (find "$for_each_item_in" -maxdepth 1 ! -path "$for_each_item_in" -print0 2>/dev/null | sort -z > "$__temp_var__temp_folder/pipe_for_while_$__NESTED_WHILE_COUNTER" &); while read -d $'\0' each
do
    # make sure its a file
    if [[ -f "$each" ]]; then
        echo "[.bashrc] loading: $each"
        . "$each"
    fi
done < "$__temp_var__temp_folder/pipe_for_while_$__NESTED_WHILE_COUNTER";__NESTED_WHILE_COUNTER="$((__NESTED_WHILE_COUNTER - 1))"; unset for_each_item_in;