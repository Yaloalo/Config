#!/bin/bash

# Get date and time
datetime=$(date "+%Y-%m-%d %H:%M:%S")

# Get battery info
battery_path=$(upower -e | grep battery | head -n 1)
if [ -n "$battery_path" ]; then
    battery_percentage=$(upower -i "$battery_path" | awk '/percentage/ {print $2}')
    battery_state=$(upower -i "$battery_path" | awk '/state/ {print $2}')
    battery_text="$battery_percentage ($battery_state)"
else
    battery_text="No battery detected"
fi

# Get network info
network=$(nmcli -t -f DEVICE,STATE,CONNECTION device | grep ":connected" | awk -F: '{print $1 " → " $3}')
if [ -z "$network" ]; then
    network="No active connection"
fi

# Compose message body with Nerd Font symbols
message=" $datetime
 Battery: $battery_text
 Network: $network"

# Send low-urgency notification
notify-send -u low "System Info" "$message"
