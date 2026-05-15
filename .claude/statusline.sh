#!/bin/bash
# Claude Code status line: shows model, context %, and first 30 chars of last user prompt.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "claude"')
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // "0"')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')

last_prompt=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    # Walk the transcript backward, find the most recent real user prompt
    # (isSidechain=false, content is a string, not a slash-command/caveat/system message).
    last_prompt=$(tail -r "$transcript" 2>/dev/null | jq -r '
        select(.type == "user")
        | select(.isSidechain == false)
        | select(.message.content | type == "string")
        | .message.content
        | select(
            (startswith("<command-") | not)
            and (startswith("Caveat:") | not)
            and (startswith("[Request interrupted") | not)
            and (. != "")
          )
        | gsub("<system-reminder>[\\s\\S]*?</system-reminder>"; "")
        | gsub("^\\s+|\\s+$"; "")
        | select(. != "")
    ' 2>/dev/null | head -n 1)
fi

# Truncate to 30 chars and replace newlines with spaces
if [ -n "$last_prompt" ]; then
    last_prompt=$(printf '%s' "$last_prompt" | tr '\n' ' ' | cut -c1-70)
    printf '%s | ctx: %s%% | last: %s' "$model" "$used" "$last_prompt"
else
    printf '%s | ctx: %s%%' "$model" "$used"
fi
