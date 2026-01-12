#!/usr/bin/env sh
# ~/.config/hypr/toggle_blur.sh
#
# SUPER+B toggles between:
#   SOFT  = small blur + slight darkening (readable background)
#   HEAVY = strong blur + darker + more vibrancy ("privacy" / bloom effect)

# SOFT profile (matches hyprland.conf defaults)
SOFT_SIZE=1
SOFT_PASSES=1
SOFT_BRIGHT=0.80
SOFT_VIBRANCY=0.20
SOFT_CONTRAST=1.0

# HEAVY profile
HEAVY_SIZE=20
HEAVY_PASSES=3
HEAVY_BRIGHT=0.40
HEAVY_VIBRANCY=0.65
HEAVY_CONTRAST=1.05

# Read current blur size from hyprctl
CUR_SIZE=$(hyprctl getoption decoration:blur:size | awk '/int:/ {print $2}')

if [ "$CUR_SIZE" = "$HEAVY_SIZE" ]; then
  # Currently HEAVY → switch to SOFT
  hyprctl keyword decoration:blur:enabled 1
  hyprctl keyword decoration:blur:size "$SOFT_SIZE"
  hyprctl keyword decoration:blur:passes "$SOFT_PASSES"
  hyprctl keyword decoration:blur:brightness "$SOFT_BRIGHT"
  hyprctl keyword decoration:blur:vibrancy "$SOFT_VIBRANCY"
  hyprctl keyword decoration:blur:contrast "$SOFT_CONTRAST"
else
  # Currently SOFT (or anything else) → switch to HEAVY
  hyprctl keyword decoration:blur:enabled 1
  hyprctl keyword decoration:blur:size "$HEAVY_SIZE"
  hyprctl keyword decoration:blur:passes "$HEAVY_PASSES"
  hyprctl keyword decoration:blur:brightness "$HEAVY_BRIGHT"
  hyprctl keyword decoration:blur:vibrancy "$HEAVY_VIBRANCY"
  hyprctl keyword decoration:blur:contrast "$HEAVY_CONTRAST"
fi

# Shared settings for both modes
hyprctl keyword decoration:blur:ignore_opacity 1
hyprctl keyword decoration:blur:new_optimizations 1

