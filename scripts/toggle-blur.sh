#!/usr/bin/env bash
set -euo pipefail

# Read the live value so this also works after eco mode or manual changes.
blur_state=$(hyprctl getoption decoration:blur:enabled -j | jq -r '.bool')
case "$blur_state" in
    true) blur_next=false ;;
    false) blur_next=true ;;
    *) printf 'Cannot read Hyprland blur state\n' >&2; exit 1 ;;
esac
hyprctl eval "hl.config({decoration={blur={enabled=$blur_next}}})" >/dev/null
