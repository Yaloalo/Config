#!/usr/bin/env bash

#
# This script toggles between laptop (eDP-1) and external (DP-7) displays
# on Hyprland. It:
#   1) detects if DP-7 is connected and enabled
#   2) decides whether to switch to external-only or laptop-only
#   3) issues the appropriate `hyprctl keyword` commands
#
# Usage:
#   Simply run this script. It will send a desktop notification
#   to confirm which mode was selected.
#

# 1) Check if external monitor DP-7 exists and is not disabled
#    We look for "Monitor DP-7" AND "disabled: false" on ANY lines thereafter.
EXTERNAL_ENABLED=$(hyprctl monitors | awk '
  /Monitor DP-7/ { seen=1 }
  seen && /disabled: false/ { print; exit }
')

if [[ -n "$EXTERNAL_ENABLED" ]]; then
    # At this point, DP-7 is connected/enabled
    #
    # 2) Find which monitor(s) are currently not disabled.
    #
    #    We capture all lines "Monitor <name>" then check each <name> to see
    #    if "disabled: false" appears in its block. This tells us whether
    #    that output is currently “active” (i.e. not disabled).
    #
    #    We build a small Bash array ACTIVE_MONITORS that contains all
    #    names of monitors whose "disabled:" line is "false".
    #
    #    (We assume each monitor block begins with "Monitor <name>" and
    #    ends just before the next "Monitor <other-name>".)
    #
    mapfile -t ACTIVE_MONITORS < <(hyprctl monitors | awk '
      /^Monitor / {
        monname=$2      # e.g. "eDP-1" or "DP-7"
        disabled="unknown"
      }
      /disabled:/ {
        disabled=$2     # e.g. "false" or "true"
        if (disabled == "false") {
          print monname
        }
      }
    ')

    # Now ACTIVE_MONITORS is an array containing one or two entries.
    # For example, when both eDP-1 and DP-7 are enabled, it will be:
    #    ACTIVE_MONITORS=( "eDP-1" "DP-7" )
    #
    # We can test them like this:
    #
    has_laptop=false
    has_external=false
    for m in "${ACTIVE_MONITORS[@]}"; do
        if [[ "$m" == "eDP-1" ]]; then
            has_laptop=true
        elif [[ "$m" == "DP-7" ]]; then
            has_external=true
        fi
    done

    # 3a) If both laptop and external are active → switch to external only
    if [[ "$has_laptop" == true && "$has_external" == true ]]; then
        hyprctl keyword monitor eDP-1,disable
        hyprctl keyword monitor DP-7,preferred,0x0,1
        notify-send "Hyprland Display" "Switched to external monitor only"

    # 3b) If only laptop (eDP-1) is active → switch to external only
    elif [[ "$has_laptop" == true && "$has_external" == false ]]; then
        hyprctl keyword monitor eDP-1,disable
        hyprctl keyword monitor DP-7,preferred,0x0,1
        notify-send "Hyprland Display" "Switched to external monitor only"

    # 3c) Otherwise (external only) → switch to laptop only
    else
        hyprctl keyword monitor eDP-1,disable
        hyprctl keyword monitor DP-7,preferred,0x0,1
        notify-send "Hyprland Display" "Switched to laptop monitor only"
    fi

else
    #
    # If DP-7 is not connected or is disabled, force eDP-1 as primary
    #
    hyprctl keyword monitor eDP-1,preferred,0x0,1
    hyprctl keyword monitor DP-7,disable
    notify-send "Hyprland Display" "No active external monitor detected; using laptop screen only"
fi
