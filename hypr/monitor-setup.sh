#!/bin/bash

# Toggle display modes between laptop (eDP-1) and external monitor (DP-7)

# Check if external monitor DP-7 is connected (appears in hyprctl)
CONNECTED=$(hyprctl monitors | grep "DP-1")

if [[ -n "$CONNECTED" ]]; then
    # External monitor exists → check what's active
    ACTIVE=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

    if [[ "$ACTIVE" == *"eDP-1"* && "$ACTIVE" == *"DP-7"* ]]; then
        # Both active → switch to external only
        hyprctl keyword monitor eDP-1,disable
        hyprctl keyword monitor DP-7,preferred,0x0,1
        notify-send "Hyprland Display" "Switched to external monitor only"
    elif [[ "$ACTIVE" == *"eDP-1"* ]]; then
        # Only laptop active → switch to external only
        hyprctl keyword monitor eDP-1,disable
        hyprctl keyword monitor DP-7,preferred,0x0,1
        notify-send "Hyprland Display" "Switched to external monitor only"
    else
        # External only → switch to laptop only
        hyprctl keyword monitor DP-7,disable
        hyprctl keyword monitor eDP-1,preferred,0x0,1
        notify-send "Hyprland Display" "Switched to laptop monitor only"
    fi
else
    # External monitor not connected → ensure laptop screen is on
    hyprctl keyword monitor eDP-1,preferred,0x0,1
    notify-send "Hyprland Display" "No external monitor detected; using laptop screen only"
fi
