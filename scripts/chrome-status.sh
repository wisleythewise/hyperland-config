#!/bin/bash
# Chrome status indicator for waybar

# Check if pre-warmed Chrome exists in minimized workspace
PREWARMED=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class == "chromium" and .workspace.name == "special:minimized")' 2>/dev/null)

# Check if prewarm script is running
PREWARM_RUNNING=$(pgrep -f "browser-prewarm.sh" 2>/dev/null)

if [ -n "$PREWARMED" ]; then
    # Chrome is pre-warmed and ready
    echo '{"text": "󰊯", "tooltip": "Chrome ready", "class": "ready"}'
elif [ -n "$PREWARM_RUNNING" ]; then
    # Prewarm script running but Chrome not ready yet
    echo '{"text": "󰊯", "tooltip": "Chrome loading...", "class": "loading"}'
else
    # No prewarm script and no Chrome
    echo '{"text": "󰊯", "tooltip": "Chrome not pre-warmed", "class": "inactive"}'
fi
