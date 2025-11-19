#!/usr/bin/env bash
# Toggle hide/unhide for ONE window at a time - Super+Shift+X

HIDE_DIR="$HOME/.cache/hypr-hidden-windows"
STATE_FILE="$HIDE_DIR/current_hidden"
mkdir -p "$HIDE_DIR"

# Check if there's already a hidden window
if [ -f "$STATE_FILE" ]; then
    HIDDEN_ADDR=$(cat "$STATE_FILE")

    # Verify the window still exists in hidden workspace
    STILL_HIDDEN=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$HIDDEN_ADDR\" and .workspace.name == \"special:hidden\") | .address")

    if [ -n "$STILL_HIDDEN" ]; then
        # Get current active workspace
        CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

        # Restore the hidden window to current workspace
        hyprctl dispatch movetoworkspace "$CURRENT_WS,address:${HIDDEN_ADDR}"

        # Ensure the window is tiled (not floating)
        IS_FLOATING=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$HIDDEN_ADDR\") | .floating")
        if [ "$IS_FLOATING" = "true" ]; then
            hyprctl dispatch togglefloating "address:${HIDDEN_ADDR}"
        fi

        # Focus the restored window
        hyprctl dispatch focuswindow "address:${HIDDEN_ADDR}"

        notify-send "Window Restored" "Moved to workspace $CURRENT_WS as tiled"
        rm "$STATE_FILE"
        exit 0
    else
        # State file exists but window isn't hidden anymore, clean up
        rm "$STATE_FILE"
    fi
fi

# No hidden window exists, hide the current window
ACTIVE_WINDOW=$(hyprctl activewindow -j | jq -r '.address')

if [ "$ACTIVE_WINDOW" = "null" ] || [ -z "$ACTIVE_WINDOW" ]; then
    notify-send "Toggle Hide" "No active window to hide"
    exit 1
fi

# Store this window as the hidden one
echo "$ACTIVE_WINDOW" > "$STATE_FILE"

# Move the window to the hidden workspace silently
hyprctl dispatch movetoworkspacesilent special:hidden,address:${ACTIVE_WINDOW}

notify-send "Window Hidden" "Press Super+Shift+X again to restore it"
