#!/bin/bash
# Move active window to workspace (creates if needed)
# Usage: workspace-move.sh [next|prev]

DIRECTION=$1

# Get current active workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Calculate target workspace
if [ "$DIRECTION" = "next" ]; then
    TARGET_WS=$((CURRENT_WS + 1))
    if [ $TARGET_WS -gt 10 ]; then
        TARGET_WS=1
    fi
elif [ "$DIRECTION" = "prev" ]; then
    TARGET_WS=$((CURRENT_WS - 1))
    if [ $TARGET_WS -lt 1 ]; then
        TARGET_WS=10
    fi
else
    exit 1
fi

# Move window to target workspace and follow it
hyprctl dispatch movetoworkspace $TARGET_WS

# Switch to that workspace to follow the window
hyprctl dispatch workspace $TARGET_WS
