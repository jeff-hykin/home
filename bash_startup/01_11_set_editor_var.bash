# if code exists
if [ -n "$(command -v "code")" ]
then
    export VISUAL="code"
    export EDITOR="$VISUAL"
else
    # if nano exists
    if [ -n "$(command -v "nano")" ]
    then
        export VISUAL="nano"
        export EDITOR="$VISUAL"
    fi
fi