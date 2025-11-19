#!/usr/bin/env bash
# Clean up windows stuck in special workspaces and move them to workspace 1

echo "Finding windows in special workspaces..."

# Get all windows in special:special
SPECIAL_WINDOWS=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:special") | .address')

# Get all windows in special:scratchpad (except intentional scratchpad windows)
SCRATCHPAD_WINDOWS=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:scratchpad" and .tags != "terminal*") | .address')

COUNT=0

# Move special:special windows to workspace 1
for ADDR in $SPECIAL_WINDOWS; do
    if [ -n "$ADDR" ]; then
        echo "Moving window $ADDR from special:special to workspace 1"
        hyprctl dispatch movetoworkspace "1,address:${ADDR}"
        COUNT=$((COUNT + 1))
    fi
done

# Move unintentional scratchpad windows to workspace 1
for ADDR in $SCRATCHPAD_WINDOWS; do
    if [ -n "$ADDR" ]; then
        echo "Moving window $ADDR from special:scratchpad to workspace 1"
        hyprctl dispatch movetoworkspace "1,address:${ADDR}"
        COUNT=$((COUNT + 1))
    fi
done

if [ $COUNT -eq 0 ]; then
    echo "No windows found in problematic special workspaces"
    notify-send "Cleanup" "No windows to recover"
else
    echo "Moved $COUNT window(s) to workspace 1"
    notify-send "Cleanup Complete" "Moved $COUNT window(s) to workspace 1"
    hyprctl dispatch workspace 1
fi
