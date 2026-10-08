#!/usr/bin/env bash

datetime=$(date "+%Y-%m-%d %H:%M:%S")

battery_path=$(upower -e | awk '/battery/ { print; exit }')
if [[ -n "$battery_path" ]]; then
    read -r battery_percentage battery_state < <(
        upower -i "$battery_path" | awk -F': +' '
            /percentage:/ { pct=$2 }
            /state:/ { state=$2 }
            END { print pct, state }
        '
    )
    battery_text="${battery_percentage:-Unknown} (${battery_state:-unknown})"
else
    battery_text="No battery detected"
fi

network=$(
    nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status \
        | awk -F: '$3 == "connected" && $2 != "loopback" { print $1 " -> " $4; exit }'
)
if [[ -z "$network" ]]; then
    network="No active connection"
fi

printf -v message 'Time: %s\nBattery: %s\nNetwork: %s' \
    "$datetime" \
    "$battery_text" \
    "$network"

notify-send -u low -a "system-info" -r 991199 "System Info" "$message"
