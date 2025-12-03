#!/bin/bash
# Minimal power menu using rofi

options="Lock\nLogout\nSuspend\nReboot\nShutdown"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "" \
    -theme-str 'window {fullscreen: true; background-color: #000000;}' \
    -theme-str 'mainbox {background-color: transparent; children: [listview]; padding: 35% 40%;}' \
    -theme-str 'listview {lines: 5; columns: 1; scrollbar: false; background-color: transparent; border: 0; layout: vertical; spacing: 0; dynamic: false;}' \
    -theme-str 'element {padding: 20px 80px; background-color: transparent; text-color: #888888; border-radius: 0;}' \
    -theme-str 'element selected {background-color: #111111; text-color: #ffffff; border-radius: 0;}' \
    -theme-str 'element-text {background-color: transparent; text-color: inherit; font: "JetBrainsMono Nerd Font 16"; horizontal-align: 0.5;}' \
    -theme-str 'element-icon {enabled: false;}')

case "$chosen" in
    "Lock") $HOME/.config/hypr/scripts/LockScreen.sh ;;
    "Logout") hyprctl dispatch exit 0 ;;
    "Suspend") systemctl suspend ;;
    "Reboot") systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
esac
