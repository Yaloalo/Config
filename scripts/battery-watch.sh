#!/usr/bin/env bash
#
# battery-watch.sh — notify always, show percentage + state, no command-line output

DEV=/org/freedesktop/UPower/devices/battery_BAT0

# Extract battery state and percentage
state=$(upower -i "$DEV" | awk -F': +' '/state:/ {print $2}')
pct=$(upower -i "$DEV" | awk -F': +' '/percentage:/ {print $2}' | tr -d '%')

# Build message text
message="Battery ${pct}% (${state})"

# Send notification based on percentage
if (( pct < 20 )); then
  notify-send -u critical "Battery Critical" "$message"
elif (( pct < 50 )); then
  notify-send -u normal "Battery Low" "$message"
else
  notify-send -u low "Battery Status" "$message"
fi
