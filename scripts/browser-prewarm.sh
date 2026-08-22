#!/bin/bash
# Pre-warm Google Chrome to avoid cold-start delay.
# Keeps ONE blank window on special:minimized and never steals user windows.

BROWSER_CMD="google-chrome-stable"
BROWSER_CLASS="google-chrome"
WARM_TITLE_RE='about:blank'
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-chrome-prewarm"
STATE_FILE="$STATE_DIR/warm_address"
mkdir -p "$STATE_DIR"

SPAWNING=false

chrome_clients() {
    hyprctl clients -j 2>/dev/null | jq -c --arg cls "$BROWSER_CLASS" '
        [.[] | select(.class == $cls)]
    '
}

# True if any Chrome window exists outside the warm stash
user_chrome_visible() {
    chrome_clients | jq -e --arg warm "$STATE_DIR" '
        .[] | select(.workspace.name != "special:minimized")
    ' >/dev/null 2>&1
}

# True if our stashed warm window still exists
warm_window_alive() {
    local addr
    addr=$(cat "$STATE_FILE" 2>/dev/null) || return 1
    [ -n "$addr" ] || return 1
    chrome_clients | jq -e --arg a "$addr" '
        .[] | select(.address == $a and .workspace.name == "special:minimized")
    ' >/dev/null 2>&1
}

spawn_warm() {
    if [ "$SPAWNING" = true ]; then
        return
    fi
    # Never prewarm while the user is actively using Chrome (profile picker, real tabs, etc.)
    if user_chrome_visible; then
        return
    fi
    if warm_window_alive; then
        return
    fi

    SPAWNING=true
    rm -f "$STATE_FILE"

    # Launch a dedicated blank window we own. Use about:blank only so we never
    # match a real "New Tab" from profile selection.
    "$BROWSER_CMD" --new-window about:blank &

    for _ in $(seq 1 25); do
        sleep 0.4
        # Abort if the user opened Chrome themselves while we were spawning
        if user_chrome_visible; then
            # If multiple blanks appeared, only stash one that is still about:blank
            :
        fi

        ADDR=$(chrome_clients | jq -r --arg re "$WARM_TITLE_RE" '
            .[]
            | select(
                (.title | test($re))
                and .workspace.name != "special:minimized"
              )
            | .address
        ' | head -1)

        if [ -n "$ADDR" ]; then
            # Only stash if there is still no other non-minimized Chrome that looks like user work
            OTHER=$(chrome_clients | jq -r --arg a "$ADDR" --arg re "$WARM_TITLE_RE" '
                .[]
                | select(
                    .address != $a
                    and .workspace.name != "special:minimized"
                    and ((.title | test($re)) | not)
                  )
                | .address
            ' | head -1)
            if [ -n "$OTHER" ]; then
                # User has a real window; leave the blank alone / let Chrome manage it
                SPAWNING=false
                return
            fi

            hyprctl dispatch movetoworkspacesilent "special:minimized,address:$ADDR" >/dev/null
            echo "$ADDR" > "$STATE_FILE"
            SPAWNING=false
            return
        fi
    done
    SPAWNING=false
}

sleep 5

if ! warm_window_alive && ! user_chrome_visible; then
    spawn_warm
fi

while true; do
    sleep 20
    if [ "$SPAWNING" = false ]; then
        if ! warm_window_alive && ! user_chrome_visible; then
            # Also skip if any chrome process window exists at all (incl. minimized user tabs)
            if ! chrome_clients | jq -e 'length > 0' >/dev/null 2>&1; then
                spawn_warm
            fi
        fi
    fi
done
