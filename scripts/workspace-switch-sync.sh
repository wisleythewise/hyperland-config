#!/bin/bash
# Paired workspace switching for dual monitors
# Laptop (eDP-1): workspaces 1-5, External (DP-1): workspaces 6-10
# They switch together: 1+6, 2+7, 3+8, 4+9, 5+10
# Usage: workspace-switch-sync.sh [next|prev]

DIRECTION=$1

# Monitor names
LAPTOP="eDP-1"
EXTERNAL="DP-1"

# Get current workspace on laptop
CURRENT_LAPTOP_WS=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$LAPTOP\") | .activeWorkspace.id")

# If laptop workspace doesn't exist or is outside range, default to 1
if [ -z "$CURRENT_LAPTOP_WS" ] || [ "$CURRENT_LAPTOP_WS" -lt 1 ] || [ "$CURRENT_LAPTOP_WS" -gt 5 ]; then
    CURRENT_LAPTOP_WS=1
fi

# Calculate new workspace based on direction
if [ "$DIRECTION" = "next" ]; then
    NEW_LAPTOP_WS=$((CURRENT_LAPTOP_WS + 1))
    [ $NEW_LAPTOP_WS -gt 5 ] && NEW_LAPTOP_WS=1
elif [ "$DIRECTION" = "prev" ]; then
    NEW_LAPTOP_WS=$((CURRENT_LAPTOP_WS - 1))
    [ $NEW_LAPTOP_WS -lt 1 ] && NEW_LAPTOP_WS=5
else
    echo "Usage: $0 [next|prev]"
    exit 1
fi

# Calculate corresponding external workspace (laptop + 5)
NEW_EXTERNAL_WS=$((NEW_LAPTOP_WS + 5))

# Get focused monitor to return to it later
FOCUSED=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

# Switch laptop to new workspace
hyprctl dispatch focusmonitor "$LAPTOP" >/dev/null 2>&1
sleep 0.05
hyprctl dispatch workspace "$NEW_LAPTOP_WS" >/dev/null 2>&1

# Switch external to corresponding workspace (if connected)
if hyprctl monitors -j | jq -e ".[] | select(.name == \"$EXTERNAL\")" >/dev/null 2>&1; then
    hyprctl dispatch focusmonitor "$EXTERNAL" >/dev/null 2>&1
    sleep 0.05
    hyprctl dispatch workspace "$NEW_EXTERNAL_WS" >/dev/null 2>&1
fi

# Return to originally focused monitor
sleep 0.05
hyprctl dispatch focusmonitor "$FOCUSED" >/dev/null 2>&1
