
#!/usr/bin/env sh
# ~/.config/hypr/toggle_blur.sh

# Query the current blur state (1 = on, 0 = off)
BLUR_STATE=$(hyprctl getoption decoration:blur:enabled | awk 'NR==1{print $2}')

if [ "$BLUR_STATE" = "1" ]; then
  # Turn blur off
  hyprctl keyword decoration:blur:enabled 0
else
  # Turn blur on
  hyprctl keyword decoration:blur:enabled 1
fi
