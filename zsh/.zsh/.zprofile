
# Login-shell only setup

# Load colors for ls, grep, etc.
if [[ -r /etc/DIR_COLORS ]]; then
  eval "$(dircolors -b /etc/DIR_COLORS)"
fi

# Allow local root X apps
xhost +local:root &>/dev/null
