#!/bin/bash

# Check if external monitor DP-1 is both listed and active
EXTERNAL_ACTIVE=$(hyprctl monitors | grep "DP-1" | grep "yes")  # looks for DP-1 and 'yes' (active flag)

if [[ -n "$EXTERNAL_ACTIVE" ]]; then
    # External monitor is connected and active
    ACTIVE=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

    if [[ "$ACTIVE" == *"eDP-1"* && "$ACTIVE" == *"DP-1"* ]]; then
        # Both active → switch to external only
        hyprctl keyword monitor eDP-1,disable
        hyprctl keyword monitor DP-1,preferred,0x0,1
        notify-send "Hyprland Display" "Switched to external monitor only"
    elif [[ "$ACTIVE" == *"eDP-1"* ]]; then
        # Only laptop active → switch to external only
        hyprctl keyword monitor eDP-1,disable
        hyprctl keyword monitor DP-1,preferred,0x0,1
        notify-send "Hyprland Display" "Switched to external monitor only"
    else
        # External only → switch to laptop only
        hyprctl keyword monitor DP-1,disable
        hyprctl keyword monitor eDP-1,preferred,0x0,1
        notify-send "Hyprland Display" "Switched to laptop monitor only"
    fi
else
    # External monitor is not active → ensure laptop screen is on
    hyprctl keyword monitor eDP-1,preferred,0x0,1
    hyprctl keyword monitor DP-1,disable
    notify-send "Hyprland Display" "No active external monitor detected; using laptop screen only"
fi
