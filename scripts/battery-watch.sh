
#!/usr/bin/env bash
#
# battery-watch.sh — warn at 50%, alarm at 20%
#

DEV=/org/freedesktop/UPower/devices/battery_BAT0

# read state & pct
read -r state pct <<< $(
  upower -i "$DEV" \
    | awk '/state:/ {s=$2} /percentage:/ {p=$2} END{print s, p}'
)

pct=${pct%\%}

# only when discharging
[[ $state != "discharging" ]] && exit 0

if   (( pct < 20 )); then
  notify-send -u critical "Battery Critical" "${pct}% remaining"
elif (( pct < 50 )); then
  notify-send -u normal   "Battery Low"      "${pct}% remaining"
fi
