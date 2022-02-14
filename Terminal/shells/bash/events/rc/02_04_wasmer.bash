# Wasmer
if [ -d "$HOME/.wasmer" ]
then
    export WASMER_DIR="$HOME/.wasmer"
    [ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"
fi