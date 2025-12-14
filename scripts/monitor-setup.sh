#!/bin/bash
# Automatic monitor configuration script for Hyprland
# This script will automatically configure monitors when they are plugged in or unplugged

# Get the list of connected monitors
LAPTOP_MONITOR="eDP-1"
DP_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.name == "DP-1") | .name')
HDMI_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.name == "HDMI-A-2") | .name')

if [ -n "$DP_MONITOR" ]; then
    # External monitor (DP-1) is connected
    echo "External monitor (DP-1) detected, configuring dual monitor setup..."
    EXTERNAL_MONITOR="DP-1"

    # Set up external monitor (Samsung ultrawide) on the left
    hyprctl keyword monitor "DP-1,3440x1440@50,0x0,1"

    # Set up laptop monitor on the right
    hyprctl keyword monitor "$LAPTOP_MONITOR,2048x1280@120,3440x0,1"

    # Assign workspaces
    hyprctl keyword workspace "1,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "2,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "3,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "4,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "5,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "6,monitor:DP-1"
    hyprctl keyword workspace "7,monitor:DP-1"
    hyprctl keyword workspace "8,monitor:DP-1"
    hyprctl keyword workspace "9,monitor:DP-1"
    hyprctl keyword workspace "10,monitor:DP-1"

    # Apply wallpaper to external monitor
    CURRENT_WALLPAPER=$(swww query | grep "$LAPTOP_MONITOR" | sed 's/.*image: //')
    if [ -n "$CURRENT_WALLPAPER" ] && [ -f "$CURRENT_WALLPAPER" ]; then
        swww img "$CURRENT_WALLPAPER" --outputs DP-1
    fi

    notify-send "Monitor Setup" "Dual monitor configuration applied" -i display
elif [ -n "$HDMI_MONITOR" ]; then
    # HDMI monitor is connected
    echo "External monitor (HDMI-A-2) detected, configuring dual monitor setup..."
    EXTERNAL_MONITOR="HDMI-A-2"

    # Set up HDMI monitor on the left
    hyprctl keyword monitor "HDMI-A-2,1920x1080@60,0x0,1"

    # Set up laptop monitor on the right
    hyprctl keyword monitor "$LAPTOP_MONITOR,2048x1280@120,1920x0,1"

    # Assign workspaces
    hyprctl keyword workspace "1,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "2,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "3,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "4,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "5,monitor:$LAPTOP_MONITOR"
    hyprctl keyword workspace "6,monitor:HDMI-A-2"
    hyprctl keyword workspace "7,monitor:HDMI-A-2"
    hyprctl keyword workspace "8,monitor:HDMI-A-2"
    hyprctl keyword workspace "9,monitor:HDMI-A-2"
    hyprctl keyword workspace "10,monitor:HDMI-A-2"

    # Apply wallpaper to external monitor
    CURRENT_WALLPAPER=$(swww query | grep "$LAPTOP_MONITOR" | sed 's/.*image: //')
    if [ -n "$CURRENT_WALLPAPER" ] && [ -f "$CURRENT_WALLPAPER" ]; then
        swww img "$CURRENT_WALLPAPER" --outputs HDMI-A-2
    fi

    notify-send "Monitor Setup" "Dual monitor configuration applied" -i display
else
    # Only laptop monitor
    echo "Only laptop monitor, configuring single monitor setup..."
    hyprctl keyword monitor "$LAPTOP_MONITOR,2048x1280@120,0x0,1"

    notify-send "Monitor Setup" "Single monitor configuration applied" -i display
fi
