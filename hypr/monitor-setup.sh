#!/usr/bin/env bash
#
# toggle_workspaces.sh — toggle between two Hyprland layouts
# by creating all workspaces then mapping them.
#
# Mode 1: WS 11 → DP‑8; WS 1–10 & 12 → eDP‑1
# Mode 2: WS 1–12 → HDMI‑A‑1
#
# Requires:
#   • hyprctl  (Hyprland’s CLI)
#   • jq        (only for reading current focused WS)

set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────────────────
STATEFILE="/tmp/hypr_ws_toggle_state"
MON_EDP="eDP-1"
MON_HDMI="HDMI-A-1"
MON_DP="DP-9"
WS_SPECIAL=11
WS_MAX=12

# ── Init state (1 → next run = Mode 1) ────────────────────────────────────────────
if [[ ! -f "$STATEFILE" ]]; then
  echo "1" > "$STATEFILE"
fi
state=$(<"$STATEFILE")

# ── Remember where you started so we can jump back ───────────────────────────────
orig_ws=$(hyprctl -j workspaces | jq -r '.[] | select(.focused).id')

# ── Function to create & move a workspace ────────────────────────────────────────
create_and_move() {
  local ws=$1 dest=$2
  # switch to it (this creates it if missing) and then move it
  hyprctl dispatch workspace "$ws"
  hyprctl dispatch moveworkspacetomonitor "$ws" "$dest"
}

# ── Perform toggle ────────────────────────────────────────────────────────────────
if [[ "$state" == "1" ]]; then
  # → Mode 1
  for ws in $(seq 1 $WS_MAX); do
    if (( ws == WS_SPECIAL )); then
      create_and_move "$ws" "$MON_DP"
    else
      create_and_move "$ws" "$MON_EDP"
    fi
  done
  echo "2" > "$STATEFILE"
  echo "Switched to Mode 1: WS $WS_SPECIAL → $MON_DP; others → $MON_EDP"
else
  # → Mode 2
  for ws in $(seq 1 $WS_MAX); do
    create_and_move "$ws" "$MON_HDMI"
  done
  echo "1" > "$STATEFILE"
  echo "Switched to Mode 2: WS 1–$WS_MAX → $MON_HDMI"
fi

# ── Restore your original workspace focus ────────────────────────────────────────
hyprctl dispatch workspace "$orig_ws"

