#!/bin/bash
# Monitor watcher script - detects when monitors are plugged/unplugged
# and automatically applies configuration.
#
# Toggle on/off at runtime with monitor-auto-toggle.sh (creates/removes the
# STATE_FILE below). This watcher always starts ENABLED after login/reboot.

SCRIPT_DIR="$HOME/.config/hypr/scripts"
STATE_FILE="$SCRIPT_DIR/.monitor-auto-disabled"

# Always start enabled after a login/reboot, regardless of previous state.
rm -f "$STATE_FILE"

# Use socat to listen to Hyprland socket for monitor events
socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do
    # Check if the event is a monitor connection/disconnection
    if echo "$line" | grep -q "monitoradded\|monitorremoved"; then
        # Respect the on/off toggle
        if [ -f "$STATE_FILE" ]; then
            continue
        fi
        echo "Monitor change detected: $line"
        # Wait a moment for the system to stabilize
        sleep 1
        # Apply geometry only (no workspace re-pinning) to avoid disrupting
        # workspace switching during normal use.
        "$SCRIPT_DIR/monitor-setup.sh"
    fi
done
