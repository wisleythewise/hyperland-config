#!/bin/bash
# Instant browser - shows pre-spawned hidden browser window instantly

# Check if there's a chromium window waiting in the pool
POOLED=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:browser_pool") | .address' | head -1)

if [ -n "$POOLED" ]; then
    # Move the pooled window to current workspace and focus it
    hyprctl dispatch movetoworkspace "e+0,address:$POOLED"
    hyprctl dispatch focuswindow "address:$POOLED"

    # Spawn a new hidden one for next time (in background, with delay)
    (sleep 1 && hyprctl dispatch exec "[workspace special:browser_pool silent] chromium --new-window about:blank") &
else
    # No pooled window, just open normally (slower first time)
    chromium --new-window
fi
