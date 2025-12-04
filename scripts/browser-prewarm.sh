#!/bin/bash
# Pre-warm chromium to avoid snap cold-start delay

spawn_warm() {
    chromium --new-window about:blank &
    # Wait for window to appear and get proper title
    for i in {1..10}; do
        sleep 1
        # Find about:blank window NOT already in special:minimized
        ADDR=$(hyprctl clients -j | jq -r '.[] | select(.class == "chromium" and (.title | test("about:blank|New Tab")) and .workspace.name != "special:minimized") | .address' | head -1)
        if [ -n "$ADDR" ]; then
            hyprctl dispatch movetoworkspacesilent "special:minimized,address:$ADDR"
            return
        fi
    done
}

sleep 3
spawn_warm

# Safety net: respawn if all chromium closed (check hyprland clients, not process)
while true; do
    sleep 10
    hyprctl clients -j | jq -e '.[] | select(.class == "chromium")' > /dev/null || spawn_warm
done
