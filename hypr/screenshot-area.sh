#!/usr/bin/env sh
grim -g "$(slurp)" - \
  | tee ~/Pictures/Screenshots/Screenshot-$(date +%F_%H-%M-%S).png \
  | wl-copy --type image/png \
  && notify-send "Area screenshot saved & copied"

