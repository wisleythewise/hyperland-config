#!/bin/bash
# Workspace synchronization monitor daemon
# Continuously monitors and maintains workspace pairing between monitors
# Laptop (eDP-1): 1-5, External (DP-1): 6-10
# Ensures they stay paired: 1+6, 2+7, 3+8, 4+9, 5+10

LAPTOP="eDP-1"
EXTERNAL="DP-1"

# Track last known state to detect changes
LAST_LAPTOP_WS=""
LAST_EXTERNAL_WS=""

while true; do
    # Get current workspaces on both monitors
    MONITORS_JSON=$(hyprctl monitors -j 2>/dev/null)

    # Check if both monitors are connected
    LAPTOP_EXISTS=$(echo "$MONITORS_JSON" | jq -e ".[] | select(.name == \"$LAPTOP\")" > /dev/null 2>&1 && echo "yes" || echo "no")
    EXTERNAL_EXISTS=$(echo "$MONITORS_JSON" | jq -e ".[] | select(.name == \"$EXTERNAL\")" > /dev/null 2>&1 && echo "yes" || echo "no")

    # Only sync if both monitors exist
    if [ "$LAPTOP_EXISTS" = "yes" ] && [ "$EXTERNAL_EXISTS" = "yes" ]; then
        LAPTOP_WS=$(echo "$MONITORS_JSON" | jq -r ".[] | select(.name == \"$LAPTOP\") | .activeWorkspace.id")
        EXTERNAL_WS=$(echo "$MONITORS_JSON" | jq -r ".[] | select(.name == \"$EXTERNAL\") | .activeWorkspace.id")

        # Only act if workspace changed
        if [ "$LAPTOP_WS" != "$LAST_LAPTOP_WS" ] || [ "$EXTERNAL_WS" != "$LAST_EXTERNAL_WS" ]; then
            # Calculate what the workspaces should be based on pairing
            # If laptop is 1-5, external should be laptop+5 (6-10)
            if [ "$LAPTOP_WS" -ge 1 ] && [ "$LAPTOP_WS" -le 5 ]; then
                EXPECTED_EXTERNAL=$((LAPTOP_WS + 5))

                # If external is out of sync, fix it
                if [ "$EXTERNAL_WS" != "$EXPECTED_EXTERNAL" ]; then
                    FOCUSED=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.focused == true) | .name')
                    hyprctl dispatch focusmonitor "$EXTERNAL" > /dev/null 2>&1
                    sleep 0.05
                    hyprctl dispatch workspace "$EXPECTED_EXTERNAL" > /dev/null 2>&1
                    sleep 0.05
                    hyprctl dispatch focusmonitor "$FOCUSED" > /dev/null 2>&1
                fi
            # If external is 6-10, laptop should be external-5 (1-5)
            elif [ "$EXTERNAL_WS" -ge 6 ] && [ "$EXTERNAL_WS" -le 10 ]; then
                EXPECTED_LAPTOP=$((EXTERNAL_WS - 5))

                # If laptop is out of sync, fix it
                if [ "$LAPTOP_WS" != "$EXPECTED_LAPTOP" ]; then
                    FOCUSED=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.focused == true) | .name')
                    hyprctl dispatch focusmonitor "$LAPTOP" > /dev/null 2>&1
                    sleep 0.05
                    hyprctl dispatch workspace "$EXPECTED_LAPTOP" > /dev/null 2>&1
                    sleep 0.05
                    hyprctl dispatch focusmonitor "$FOCUSED" > /dev/null 2>&1
                fi
            fi

            # Update last known state
            LAST_LAPTOP_WS="$LAPTOP_WS"
            LAST_EXTERNAL_WS="$EXTERNAL_WS"
        fi
    fi

    # Check every 200ms for responsiveness
    sleep 0.2
done
