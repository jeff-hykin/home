# if codex exists
if ! [ -n "$(command -v "codex")" ]
then
    alias codex="npx @openai/codex@0.87.0"
fi

if ! [ -n "$(command -v "pixi")" ]
then
    # if executable file
    filepath="$HOME/.pixi/bin/pixi"
    if [ -f "$filepath" ] && [ -r "$filepath" ] && [ -x "$filepath" ]; then
        export PATH="$PATH:$HOME/.pixi/bin"
        export PATH="$HOME/.cargo/bin:$PATH" 
    fi
fi
