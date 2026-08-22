#!/bin/bash
# Toggle audio output between laptop Speakers and AirPods / Bluetooth.
# If on Bluetooth -> switch to Speaker. Otherwise -> switch to Bluetooth (if connected).

iDIR="$HOME/.config/swaync/icons"

speaker=$(pactl list short sinks | awk '/Speaker__sink/{print $2; exit}')
bt=$(pactl list short sinks | awk '$2 ~ /^bluez_output/{print $2; exit}')
current=$(pactl get-default-sink)

if [[ "$current" == bluez_output* ]]; then
    target="$speaker"
elif [[ -n "$bt" ]]; then
    target="$bt"
else
    target="$speaker"
fi

[[ -z "$target" || "$target" == "$current" ]] && exit 0

pactl set-default-sink "$target"

# Move any currently-playing streams to the new output
for id in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$id" "$target"
done

# Friendly name + notification
case "$target" in
    bluez_output*) name="󰋋  AirPods" ; icon="$iDIR/volume-high.png" ;;
    *Speaker*)     name="󰓃  Speakers" ; icon="$iDIR/volume-high.png" ;;
    *HDMI*)        name="󰍹  HDMI" ; icon="$iDIR/volume-high.png" ;;
    *)             name="$target" ; icon="$iDIR/volume-high.png" ;;
esac

notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$icon" "  Audio Output" "$name"
