#!/bin/bash
# Monitor watcher script - detects when monitors are plugged/unplugged
# and automatically applies configuration

SCRIPT_DIR="$HOME/.config/hypr/scripts"

# Use socat to listen to Hyprland socket for monitor events
socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do
    # Check if the event is a monitor connection/disconnection
    if echo "$line" | grep -q "monitoradded\|monitorremoved"; then
        echo "Monitor change detected: $line"
        # Wait a moment for the system to stabilize
        sleep 1
        # Run the monitor setup script
        "$SCRIPT_DIR/monitor-setup.sh"
    fi
done
