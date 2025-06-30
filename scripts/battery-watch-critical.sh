#!/usr/bin/env bash
#
# battery-watch-critical.sh
#  — persistent critical at ≤10%
#  — auto-clear on AC or >10%
#  — uses freedesktop D-Bus Notify API

DEV=/org/freedesktop/UPower/devices/battery_BAT0
TAG="battery-critical"                  # synchronous tag
IDFILE="/tmp/${TAG}.id"

# 1) read state & percentage
read state pct < <(
  upower -i "$DEV" \
    | awk -F': +' '/state:/ {s=$2} /percentage:/ {p=int($2)} END {print s, p}'
)

# 2) if discharging ≤10%, send once
if [[ "$state" == "discharging" && $pct -le 10 ]]; then
  if [[ ! -f $IDFILE ]]; then
    # call org.freedesktop.Notifications.Notify to get a notification ID
    nid=$(
      gdbus call \
        --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
          "battery-watch" 0 "" \
          "Battery Critical: ${pct}%!" \
          "Please plug in your charger." \
          "[]" "{}" 0 \
      | sed -n 's/^(uint32 \([0-9]\+\)).*$/\1/p'
    )
    echo "$nid" > "$IDFILE"
  fi

# 3) otherwise (charging or pct>10), clear existing
else
  if [[ -f $IDFILE ]]; then
    nid=$(<"$IDFILE")
    # close by ID
    gdbus call \
      --session \
      --dest org.freedesktop.Notifications \
      --object-path /org/freedesktop/Notifications \
      --method org.freedesktop.Notifications.CloseNotification \
      "$nid"
    rm -f "$IDFILE"
  fi
fi

