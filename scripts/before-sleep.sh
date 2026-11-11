#!/usr/bin/env bash
# Run by hypridle while logind holds the sleep delay (lid close, power menu,
# systemctl suspend). hypridle releases the delay once the session is locked.

# Lock first: if anything below hangs, sleep must still happen locked.
loginctl lock-session

playerctl --all-players pause 2>/dev/null

# Free the headphones so they don't stay bound to a sleeping laptop.
bluetoothctl devices Connected | while read -r _ mac _; do
    timeout 3 bluetoothctl disconnect "$mac" >/dev/null 2>&1
done
