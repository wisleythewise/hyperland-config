#!/bin/bash
# Monitor helper for Hyprland.
#
# IMPORTANT: resolution / refresh / scale / position are NOT set here anymore.
# Those are declared in ~/.config/hypr/monitors.conf and Hyprland applies the
# matching rule automatically whenever a monitor connects (login or hotplug).
# That is what lets the JRP7003 get forced to 1080p@60 (scale 2) while any
# OTHER external monitor still comes up at its own native resolution.
#
# This script only does the things monitors.conf can't:
#   - pin workspaces 6-10 to the external monitor (login only, via --full)
#   - mirror the laptop wallpaper onto the external monitor
#
# Usage:
#   monitor-setup.sh          -> wallpaper only (safe for hotplug)
#   monitor-setup.sh --full   -> also pin workspaces (use at login only)
# Pinning workspaces on every hotplug event used to interfere with normal
# workspace switching, so it is gated behind --full.

FULL=0
[ "$1" = "--full" ] && FULL=1

LAPTOP_MONITOR="eDP-1"

# The external monitor is the first connected output that isn't the laptop panel.
EXTERNAL_MONITOR=$(hyprctl monitors -j | jq -r ".[] | select(.name != \"$LAPTOP_MONITOR\") | .name" | head -n1)

if [ -n "$EXTERNAL_MONITOR" ]; then
    echo "External monitor ($EXTERNAL_MONITOR) detected."

    # Pin workspaces (login only - see --full note above)
    if [ "$FULL" = "1" ]; then
        for ws in 1 2 3 4 5; do
            hyprctl keyword workspace "$ws,monitor:$LAPTOP_MONITOR"
        done
        for ws in 6 7 8 9 10; do
            hyprctl keyword workspace "$ws,monitor:$EXTERNAL_MONITOR"
        done
    fi

    # Mirror the laptop's current wallpaper onto the external monitor
    CURRENT_WALLPAPER=$(swww query | grep "$LAPTOP_MONITOR" | sed 's/.*image: //')
    if [ -n "$CURRENT_WALLPAPER" ] && [ -f "$CURRENT_WALLPAPER" ]; then
        swww img "$CURRENT_WALLPAPER" --outputs "$EXTERNAL_MONITOR"
    fi

    notify-send "Monitor Setup" "External monitor ($EXTERNAL_MONITOR) configured" -i display
else
    echo "Only laptop monitor connected."
    notify-send "Monitor Setup" "Single monitor (laptop only)" -i display
fi
