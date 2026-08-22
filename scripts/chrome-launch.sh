#!/usr/bin/env bash
# Smart Chrome launcher for Super+B
# 1) Restore a pre-warmed / minimized Chrome window if present
# 2) Otherwise focus an existing Chrome window
# 3) Otherwise open a new Chrome window

BROWSER_CMD="google-chrome-stable"
BROWSER_CLASS="google-chrome"
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-chrome-prewarm/warm_address"

CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

restore_addr() {
    local addr="$1"
    [ -n "$addr" ] && [ "$addr" != "null" ] || return 1

    local exists
    exists=$(hyprctl clients -j | jq -r --arg a "$addr" \
        '.[] | select(.address == $a) | .address' | head -1)
    [ -n "$exists" ] || return 1

    hyprctl dispatch movetoworkspace "$CURRENT_WS,address:$addr" >/dev/null
    hyprctl dispatch focuswindow "address:$addr" >/dev/null
    # Clear warm marker so prewarm can make a new blank later if needed
    if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "$addr" ]; then
        rm -f "$STATE_FILE"
    fi
    return 0
}

# Prefer the tracked warm window
if [ -f "$STATE_FILE" ]; then
    if restore_addr "$(cat "$STATE_FILE")"; then
        exit 0
    fi
    rm -f "$STATE_FILE"
fi

# Any Chrome sitting on special:minimized (prewarm leftover or accidental hide)
MIN_ADDR=$(hyprctl clients -j | jq -r --arg cls "$BROWSER_CLASS" '
    .[]
    | select(.class == $cls and .workspace.name == "special:minimized")
    | .address
' | head -1)
if restore_addr "$MIN_ADDR"; then
    exit 0
fi

# Focus an already-visible Chrome window on the current / any workspace
VIS_ADDR=$(hyprctl clients -j | jq -r --arg cls "$BROWSER_CLASS" '
    .[]
    | select(.class == $cls and (.workspace.name | startswith("special:") | not))
    | .address
' | head -1)
if [ -n "$VIS_ADDR" ]; then
    hyprctl dispatch focuswindow "address:$VIS_ADDR" >/dev/null
    # Still open a fresh window so Super+B always gives you a browser surface
    exec "$BROWSER_CMD" --new-window
fi

# Cold start
exec "$BROWSER_CMD" --new-window
