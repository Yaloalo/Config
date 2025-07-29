#!/usr/bin/env bash
#
# monitor-setup.sh — toggle between:
#   • primary:   WS 1–10 & 12 → eDP-1, WS 11 → DP-7
#   • secondary: WS 1–12 → DP-7
#
# Usage (bind this to SUPER+M in hyprland.conf):
#   monitor-setup.sh            # toggle
#   monitor-setup.sh primary    # force primary layout
#   monitor-setup.sh secondary  # force secondary layout
#
# Requires: hyprctl, bash

INTERNAL="eDP-1"
EXTERNAL="DP-7"
STATE_FILE="/tmp/monitor-setup.state"

# 1) Determine mode
if [[ "$1" == "primary" ]]; then
  mode="primary"
elif [[ "$1" == "secondary" ]]; then
  mode="secondary"
else
  # toggle based on last run
  if [[ -f "$STATE_FILE" ]]; then
    last="$(<"$STATE_FILE")"
    if [[ "$last" == "primary" ]]; then
      mode="secondary"
    else
      mode="primary"
    fi
  else
    # assume you start in primary → first toggle is secondary
    mode="secondary"
  fi
fi

# persist new state
echo "$mode" > "$STATE_FILE"
echo ">>> Applying mode: $mode <<<"

# 2) Apply
for ws in {1..12}; do
  hyprctl dispatch workspace "$ws"
  if [[ "$mode" == "secondary" ]]; then
    hyprctl dispatch movecurrentworkspacetomonitor "$EXTERNAL"
  else
    # primary: only WS 11 goes external
    if [[ "$ws" -eq 11 ]]; then
      hyprctl dispatch movecurrentworkspacetomonitor "$EXTERNAL"
    else
      hyprctl dispatch movecurrentworkspacetomonitor "$INTERNAL"
    fi
  fi
done

# 3) Focus correct monitor
if [[ "$mode" == "secondary" ]]; then
  hyprctl dispatch focusmonitor "$EXTERNAL"
else
  hyprctl dispatch focusmonitor "$INTERNAL"
fi

exit 0

