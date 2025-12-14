#!/bin/bash
# Pre-warm chromium to avoid snap cold-start delay

SPAWNING=false

spawn_warm() {
    # Prevent concurrent spawns
    if [ "$SPAWNING" = true ]; then
        return
    fi
    SPAWNING=true

    chromium --new-window about:blank &
    CHROME_PID=$!

    # Wait for window to appear (increased timeout for snap cold-start)
    for i in {1..20}; do
        sleep 1
        # Find about:blank window NOT already in special:minimized
        ADDR=$(hyprctl clients -j | jq -r '.[] | select(.class == "chromium" and (.title | test("about:blank|New Tab")) and .workspace.name != "special:minimized") | .address' | head -1)
        if [ -n "$ADDR" ]; then
            hyprctl dispatch movetoworkspacesilent "special:minimized,address:$ADDR"
            SPAWNING=false
            return
        fi
    done
    SPAWNING=false
}

# Wait for Hyprland to be fully ready
sleep 5

# Only spawn if no chromium windows exist yet
if ! hyprctl clients -j | jq -e '.[] | select(.class == "chromium")' > /dev/null 2>&1; then
    spawn_warm
fi

# Safety net: respawn if all chromium closed (check hyprland clients, not process)
while true; do
    sleep 15
    if [ "$SPAWNING" = false ]; then
        hyprctl clients -j | jq -e '.[] | select(.class == "chromium")' > /dev/null || spawn_warm
    fi
done
