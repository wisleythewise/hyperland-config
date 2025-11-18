#!/bin/bash
# Workspace switching script that syncs both monitors
# Usage: workspace-switch.sh [next|prev]

DIRECTION=$1

# Get current active workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

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

# Switch to new workspace (this will be on the focused monitor)
hyprctl dispatch workspace $NEW_WS

# Get all monitors
MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

# Determine which workspaces should be on which monitor based on your setup
# Workspaces 1-5 on laptop (eDP-1), 6-10 on external (DP-1)
LAPTOP_MONITOR="eDP-1"
EXTERNAL_MONITOR="DP-1"

# Calculate the corresponding workspace for the other monitor
# If we're on workspace 1-5 (laptop), the external should be on 6-10
# If we're on workspace 6-10 (external), the laptop should be on 1-5
if [ $NEW_WS -le 5 ]; then
    # We're on laptop workspaces (1-5), sync external monitor
    EXTERNAL_WS=$((NEW_WS + 5))
    if echo "$MONITORS" | grep -q "$EXTERNAL_MONITOR"; then
        hyprctl dispatch focusmonitor $EXTERNAL_MONITOR
        hyprctl dispatch workspace $EXTERNAL_WS
        hyprctl dispatch focusmonitor $LAPTOP_MONITOR
    fi
else
    # We're on external workspaces (6-10), sync laptop monitor
    LAPTOP_WS=$((NEW_WS - 5))
    hyprctl dispatch focusmonitor $LAPTOP_MONITOR
    hyprctl dispatch workspace $LAPTOP_WS
    if echo "$MONITORS" | grep -q "$EXTERNAL_MONITOR"; then
        hyprctl dispatch focusmonitor $EXTERNAL_MONITOR
        hyprctl dispatch workspace $NEW_WS
    fi
fi
