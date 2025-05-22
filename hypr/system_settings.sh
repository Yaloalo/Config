#!/bin/bash

# Define the options
OPTIONS="Wi-Fi\nBluetooth\nSound\nDisplay\nPower"

# Use fzf to allow the user to choose an option
CHOICE=$(echo -e "$OPTIONS" | fzf --prompt="Select an option: ")

case "$CHOICE" in
  "Wi-Fi")
    nmcli device wifi connect
    ;;
  "Bluetooth")
    blueman-manager
    ;;
  "Sound")
    pavucontrol
    ;;
  "Display")
    arandr
    ;;
  "Power")
    powerdevil --status
    ;;
  *)
    echo "Invalid option"
    ;;
esac
