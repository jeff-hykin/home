# OpenClaw PATH and completions
export PATH="$HOME/.openclaw/bin:$PATH"
if [ -f "$HOME/.openclaw/completions/openclaw.zsh" ]; then
    source "$HOME/.openclaw/completions/openclaw.zsh"
fi
