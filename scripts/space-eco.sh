#!/usr/bin/env bash
set -euo pipefail
state_dir="${XDG_RUNTIME_DIR:?}/infinity-eco"
mkdir -p "$state_dir"
if [[ "${1:-}" == on ]]; then
    if [[ ! -f "$state_dir/brightness" ]]; then
        brightnessctl get > "$state_dir/brightness"
        hyprctl getoption decoration:blur:enabled -j | jq -r '.bool' > "$state_dir/blur"
        hyprctl getoption animations:enabled -j | jq -r '.bool' > "$state_dir/animations"
        if command -v powerprofilesctl >/dev/null; then powerprofilesctl get > "$state_dir/profile"; fi
    fi
    [[ ${2:-35} =~ ^[0-9]+$ ]] || exit 2
    # Eco must never increase a display that is already dimmer than the preset.
    requested=$(( $(brightnessctl max) * ${2:-35} / 100 ))
    original=$(<"$state_dir/brightness")
    (( requested > original )) && requested=$original
    brightnessctl set "$requested" >/dev/null
    blur=true; animations=true
    [[ ${3:-1} == 1 ]] && blur=false
    [[ ${4:-1} == 1 ]] && animations=false
    hyprctl eval "hl.config({decoration={blur={enabled=$blur}}, animations={enabled=$animations}})" >/dev/null
    if command -v powerprofilesctl >/dev/null; then
        powerprofilesctl set power-saver
        echo 'Eco enabled: display effects reduced; CPU power-saver active.'
    else
        echo 'Eco enabled: display effects and brightness reduced. CPU profile service is not installed.'
    fi
elif [[ "${1:-}" == off ]]; then
    if [[ -f "$state_dir/brightness" ]]; then
        brightnessctl set "$(<"$state_dir/brightness")" >/dev/null
        blur=false; animations=false
        [[ $(<"$state_dir/blur") == true ]] && blur=true
        [[ $(<"$state_dir/animations") == true ]] && animations=true
        hyprctl eval "hl.config({decoration={blur={enabled=$blur}}, animations={enabled=$animations}})" >/dev/null
        if [[ -f "$state_dir/profile" ]] && command -v powerprofilesctl >/dev/null; then
            powerprofilesctl set "$(<"$state_dir/profile")"
        fi
        rm -f "$state_dir/brightness" "$state_dir/blur" "$state_dir/animations" "$state_dir/profile"
    fi
    echo 'Previous brightness and display effects restored.'
fi
