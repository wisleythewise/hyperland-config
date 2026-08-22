#!/bin/bash
# Toggle automatic monitor (re)configuration on plug/unplug ON or OFF.
#
# When OFF, the monitor-watcher stays running but ignores plug/unplug events,
# so your manual layout (e.g. from nwg-displays / wdisplays) is left alone.
# A reboot/login always resets this back to ON (see monitor-watcher.sh).

SCRIPT_DIR="$HOME/.config/hypr/scripts"
STATE_FILE="$SCRIPT_DIR/.monitor-auto-disabled"

if [ -f "$STATE_FILE" ]; then
    # Currently disabled -> enable
    rm -f "$STATE_FILE"
    # Re-apply the correct geometry right now for whatever is plugged in
    "$SCRIPT_DIR/monitor-setup.sh"
    notify-send "Monitor Auto-Config" "ENABLED - displays auto-configure on plug/unplug" -i display
else
    # Currently enabled -> disable
    touch "$STATE_FILE"
    notify-send "Monitor Auto-Config" "DISABLED - plug/unplug will not reconfigure displays" -i display
fi
