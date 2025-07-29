#!/usr/bin/env bash
#
# monitor-setup.sh (toggle mode)
#
# Each time you run this script, it will:
#   1. Detect where workspace 1 currently lives (eDP-1 or DP-7).
#   2. If workspace 1 is on eDP-1 → move workspaces 1–5 → DP-7, then focus DP-7.
#   3. If workspace 1 is on DP-7 → move workspaces 1–5 → eDP-1, then focus eDP-1.
#
# This ensures alternating behavior each run—no external JSON or jq needed.
# Requirements: hyprctl (Hyprland CLI) and Bash.
#
# Usage: 
#   chmod +x ~/bin/monitor-setup.sh
#   ~/bin/monitor-setup.sh
# Or bind to a key via your Hyprland config:
#   bind = SUPER, M, exec, ~/bin/monitor-setup.sh

INTERNAL="eDP-1"
EXTERNAL="DP-7"

echo "=== monitor-setup.sh toggle at $(date '+%Y-%m-%d %H:%M:%S') ==="

#
# 1) Find out where workspace 1 currently is.
#    We run `hyprctl workspaces` (plain text) and grep for the line:
#      workspace ID 1 (<name>) on monitor <MONITOR>:
#    Then extract <MONITOR> via a Bash regex.
#
ws1_line=$(hyprctl workspaces | grep -E "^workspace ID 1 ")
if [[ -z "$ws1_line" ]]; then
  echo "Error: Could not find 'workspace 1' in hyprctl workspaces output."
  exit 1
fi

# Regex to pull out the monitor name for workspace 1:
#   Example: "workspace ID 1 (1) on monitor eDP-1:"
if [[ $ws1_line =~ on[[:space:]]monitor[[:space:]]([^:]+): ]]; then
  ws1_mon="${BASH_REMATCH[1]}"
  echo "Workspace 1 is currently on monitor: $ws1_mon"
else
  echo "Error: Failed to parse monitor name from: $ws1_line"
  exit 1
fi

#
# 2) Decide the destination (DST) based on ws1_mon:
#    • If ws1_mon == eDP-1 → DST=DP-7 (move out to external).
#    • Otherwise (ws1_mon == DP-7) → DST=eDP-1 (move back to laptop).
#
if [[ "$ws1_mon" == "$INTERNAL" ]]; then
  DST="$EXTERNAL"
  echo "→ Toggling: moving 1–5 from $INTERNAL → $EXTERNAL"
elif [[ "$ws1_mon" == "$EXTERNAL" ]]; then
  DST="$INTERNAL"
  echo "→ Toggling: moving 1–5 from $EXTERNAL → $INTERNAL"
else
  echo "Warning: Workspace 1 is on '$ws1_mon', which is neither $INTERNAL nor $EXTERNAL."
  echo "Defaulting to moving toward $EXTERNAL."
  DST="$EXTERNAL"
fi

#
# 3) Loop over workspaces 1–5 and move each one to $DST:
#    We do:
#      hyprctl dispatch workspace N
#      hyprctl dispatch movecurrentworkspacetomonitor $DST
#
#    Even if a workspace is already on $DST, movecurrentworkspacetomonitor <same> is a no-op.
#
for N in 1 2 3 4 5; do
  echo "   • workspace $N → $DST"
  hyprctl dispatch workspace "$N"
  hyprctl dispatch movecurrentworkspacetomonitor "$DST"
done

#
# 4) Finally, focus $DST so new windows/keystrokes land on the correct monitor:
#
echo "Focusing monitor $DST"
hyprctl dispatch focusmonitor "$DST"

echo "=== toggle complete ==="
exit 0
