# Point non-interactive bash scripts at .bashenv
export BASH_ENV="$HOME/.bashenv"

# Add Commands to PATH
mkdir -p "$HOME/Commands"
export PATH="$PATH:$HOME/Personal/Commands:$HOME/Commands"
for f in "$HOME/Commands"/*; do
    [ -f "$f" ] && chmod u+x "$f"
done

. "$HOME/.bashenv"
