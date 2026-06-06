#!/bin/bash
# Chrome status indicator for waybar

BROWSER_CLASS="google-chrome"

PREWARMED=$(hyprctl clients -j 2>/dev/null | jq -r --arg cls "$BROWSER_CLASS" '.[] | select(.class == $cls and .workspace.name == "special:minimized")' 2>/dev/null)

PREWARM_RUNNING=$(pgrep -f "browser-prewarm.sh" 2>/dev/null)

if [ -n "$PREWARMED" ]; then
    echo '{"text": "󰊯", "tooltip": "Chrome ready", "class": "ready"}'
elif [ -n "$PREWARM_RUNNING" ]; then
    echo '{"text": "󰊯", "tooltip": "Chrome loading...", "class": "loading"}'
else
    echo '{"text": "󰊯", "tooltip": "Chrome not pre-warmed", "class": "inactive"}'
fi
