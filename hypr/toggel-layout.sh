
#!/bin/bash

# Get current layout index (e.g., 0 = us, 1 = de)
current=$(hyprctl devices | awk '/at-translated-set-2-keyboard/ {f=1} f && /active layout/ {print $NF; exit}')

# Toggle index: 0 → 1, 1 → 0
next=$(( (current + 1) % 2 ))

# Apply the toggle
hyprctl switchxkblayout at-translated-set-2-keyboard $next
