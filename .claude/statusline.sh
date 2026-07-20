#!/bin/bash
# Claude Code status line: shows model, context %, and first 30 chars of last user prompt.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "claude"')
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // "0"')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')

# Weekly-limit "pace" percent.
# 100% = burning exactly 1/7th of the weekly quota per day (on track to hit 100% at week end).
# 200% = on pace to run out halfway through the week. 50% = on pace to use only half by week end.
# pace = (fraction of weekly quota used) / (fraction of week elapsed) * 100
#      = used_percentage * 604800 / elapsed_seconds   (week = 604800s)
week_pace=""
seven_pct=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_reset=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
if [ -n "$seven_pct" ] && [ -n "$seven_reset" ]; then
    now=$(date +%s)
    week_pace=$(awk -v pct="$seven_pct" -v reset="$seven_reset" -v now="$now" 'BEGIN {
        week = 604800
        elapsed = now - (reset - week)
        if (elapsed < 60) { elapsed = 60 }   # guard against div-by-zero at week start
        printf "%d", pct * week / elapsed
    }')
fi

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

# Optional weekly-pace segment
wk_seg=""
if [ -n "$week_pace" ]; then
    wk_seg=$(printf ' | wk: %s%%' "$week_pace")
fi

# Truncate to 30 chars and replace newlines with spaces
if [ -n "$last_prompt" ]; then
    last_prompt=$(printf '%s' "$last_prompt" | tr '\n' ' ' | cut -c1-70)
    printf '%s | ctx: %s%%%s | last: %s' "$model" "$used" "$wk_seg" "$last_prompt"
else
    printf '%s | ctx: %s%%%s' "$model" "$used" "$wk_seg"
fi
