#!/usr/bin/env bash
set -euo pipefail

SPECIAL_NAME="term"
WEZ_CLASS="global-term"

# Check if special workspace is currently visible on any monitor
special_visible() {
  hyprctl monitors -j \
    | jq -e ".[] | select(.specialWorkspace.name == \"special:$SPECIAL_NAME\")" \
    >/dev/null 2>&1
}

focus_global_term() {
  # Try class selector first; fall back to plain
  hyprctl dispatch focuswindow "class:$WEZ_CLASS" 2>/dev/null || \
  hyprctl dispatch focuswindow "$WEZ_CLASS" 2>/dev/null || true
}

# 1. Ensure special:term is visible, but NEVER hide it from this script
if ! special_visible; then
  hyprctl dispatch togglespecialworkspace "$SPECIAL_NAME"
fi

# 2. If wezterm with class global-term exists → new tab, else start it
if hyprctl clients -j | jq -e ".[] | select(.class == \"$WEZ_CLASS\")" >/dev/null 2>&1; then
  # Wezterm already exists → spawn a new tab in *that* window

  # 1. Get the window_id for the global-term instance
  win_id=$(
    wezterm cli --class "$WEZ_CLASS" list --format json \
      | jq '.[0].window_id'
  )

  # 2. Spawn a new tab in that window
  wezterm cli --class "$WEZ_CLASS" spawn --window-id "$win_id"
else
  # No instance yet → start global-term wezterm
  wezterm start --class "$WEZ_CLASS" --always-new-process &
fi


# 3. Focus global-term so you can type immediately
for _ in {1..10}; do
  if hyprctl clients -j | jq -e ".[] | select(.class == \"$WEZ_CLASS\")" >/dev/null 2>&1; then
    focus_global_term
    break
  fi
  sleep 0.05
done

