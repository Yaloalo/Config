#!/usr/bin/env bash
#
# move_all_workspaces.sh — send all workspaces to either laptop or desk monitor
# Logic:
#   If external monitor (HDMI-A-1) is enabled → move all WS there
#   else → move all WS to laptop panel (eDP-1)

set -euo pipefail

LAPTOP="eDP-1"
DESK="HDMI-A-1"   # adjust if needed (DP-9, etc.)

# --- figure out which monitor should be the target ------------------------------

monitors_json=$(hyprctl -j monitors)

if echo "$monitors_json" | jq -e \
   '.[] | select(.name=="'"$DESK"'") | select(.disabled==false)' >/dev/null; then
    target="$DESK"      # external is up → use that
else
    target="$LAPTOP"    # fallback to laptop panel
fi

# --- remember currently focused workspace --------------------------------------

orig_ws=$(hyprctl -j workspaces | jq -r '.[] | select(.focused).id')

# --- move all workspaces to the chosen monitor ---------------------------------

for ws in $(hyprctl -j workspaces | jq '.[].id'); do
    hyprctl dispatch moveworkspacetomonitor "$ws" "$target"
done

# --- restore focus -------------------------------------------------------------

hyprctl dispatch workspace "$orig_ws"

