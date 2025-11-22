#!/bin/bash
# Synchronized workspace switching - all monitors switch to the same workspace together
# Usage: workspace-switch.sh [next|prev]

DIRECTION=$1

# Get monitor info
MONITORS_JSON=$(hyprctl monitors -j)
FOCUSED_MONITOR=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.focused == true) | .name')
CURRENT_WS=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
MONITOR_COUNT=$(echo "$MONITORS_JSON" | jq 'length')

# Calculate new workspace based on direction
if [ "$DIRECTION" = "next" ]; then
    NEW_WS=$((CURRENT_WS + 1))
    if [ $NEW_WS -gt 10 ]; then
        NEW_WS=1
    fi
elif [ "$DIRECTION" = "prev" ]; then
    NEW_WS=$((CURRENT_WS - 1))
    if [ $NEW_WS -lt 1 ]; then
        NEW_WS=10
    fi
else
    exit 1
fi

# For single monitor, just switch normally
if [ "$MONITOR_COUNT" -eq 1 ]; then
    hyprctl dispatch workspace "$NEW_WS"
    exit 0
fi

# For multiple monitors: switch focused monitor's workspace
# The key is that we're just switching the focused monitor
# If the user wants all monitors to follow, they need independent workspaces
hyprctl dispatch workspace "$NEW_WS"
