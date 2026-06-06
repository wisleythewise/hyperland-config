#!/bin/bash
# Pre-warm Google Chrome to avoid cold-start delay

BROWSER_CMD="google-chrome-stable"
BROWSER_CLASS="google-chrome"

SPAWNING=false

spawn_warm() {
    if [ "$SPAWNING" = true ]; then
        return
    fi
    SPAWNING=true

    "$BROWSER_CMD" --new-window about:blank &
    CHROME_PID=$!

    for i in {1..20}; do
        sleep 1
        ADDR=$(hyprctl clients -j | jq -r --arg cls "$BROWSER_CLASS" '.[] | select(.class == $cls and (.title | test("about:blank|New Tab")) and .workspace.name != "special:minimized") | .address' | head -1)
        if [ -n "$ADDR" ]; then
            hyprctl dispatch movetoworkspacesilent "special:minimized,address:$ADDR"
            SPAWNING=false
            return
        fi
    done
    SPAWNING=false
}

sleep 5

if ! hyprctl clients -j | jq -e --arg cls "$BROWSER_CLASS" '.[] | select(.class == $cls)' > /dev/null 2>&1; then
    spawn_warm
fi

while true; do
    sleep 15
    if [ "$SPAWNING" = false ]; then
        hyprctl clients -j | jq -e --arg cls "$BROWSER_CLASS" '.[] | select(.class == $cls)' > /dev/null || spawn_warm
    fi
done
