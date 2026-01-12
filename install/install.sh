#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_TARGET="${XDG_CONFIG_HOME:-$HOME/.config}"

INSTALL_PACKAGES=1
ENABLE_SYSTEMD=1
SYNC_CONFIG=1

PACMAN_PACKAGES=(
  base-devel
  git
  wget
  curl
  rsync
  unzip
  jq
  socat
  fastfetch
  btop
  starship
  neovim
  ripgrep
  fd
  fzf
  python-pynvim
  nodejs
  npm
  wl-clipboard
  grim
  slurp
  waybar
  wofi
  mako
  hyprland
  hyprpaper
  hypridle
  hyprlock
  wlogout
  kanshi
  wezterm
  kitty
  tmux
  zsh
  ttf-jetbrains-mono-nerd
  brightnessctl
  playerctl
  upower
  networkmanager
  pipewire
  wireplumber
  tor
  libnotify
)

AUR_PACKAGES=(
  uwsm
  bluetui
)

TIMERS=(
  battery-watch.timer
  battery-watch-critical.timer
  bedtime.timer
)

SERVICES=(
  hyprlock-on-suspend.service
)

PROTON_SERVICES=(
  tor.service
)

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]
  --skip-packages   Do not install pacman/yay packages
  --skip-systemd    Do not enable user systemd units
  --skip-sync       Do not copy dotfiles into \$XDG_CONFIG_HOME
EOF
}

log() { printf '[*] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*" >&2; }

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-packages) INSTALL_PACKAGES=0 ;;
      --skip-systemd)  ENABLE_SYSTEMD=0 ;;
      --skip-sync)     SYNC_CONFIG=0 ;;
      -h|--help) usage; exit 0 ;;
      *) usage; exit 1 ;;
    esac
    shift
  done
}

install_pacman_packages() {
  if ! command -v pacman >/dev/null 2>&1; then
    warn "pacman not found; skipping pacman package install."
    return
  fi

  log "Installing pacman packages (${#PACMAN_PACKAGES[@]} items)..."
  sudo pacman -Syu --needed "${PACMAN_PACKAGES[@]}"
}

choose_aur_helper() {
  if command -v yay >/dev/null 2>&1; then
    echo "yay"
  elif command -v paru >/dev/null 2>&1; then
    echo "paru"
  else
    echo ""
  fi
}

install_aur_packages() {
  [[ ${#AUR_PACKAGES[@]} -gt 0 ]] || return

  local helper
  helper="$(choose_aur_helper)"

  if [[ -z "$helper" ]]; then
    warn "No AUR helper found (yay/paru). Skipping AUR packages: ${AUR_PACKAGES[*]}"
    return
  fi

  log "Installing AUR packages via $helper..."
  "$helper" -S --needed "${AUR_PACKAGES[@]}"
}

sync_dotfiles() {
  mkdir -p "$CONFIG_TARGET"

  if [[ "$REPO_ROOT" == "$CONFIG_TARGET" ]]; then
    log "Repository already lives in $CONFIG_TARGET; skipping sync."
    return
  fi

  if ! command -v rsync >/dev/null 2>&1; then
    warn "rsync missing; copying with cp -a instead."
    cp -a "$REPO_ROOT"/. "$CONFIG_TARGET"/
    return
  fi

  log "Syncing dotfiles into $CONFIG_TARGET"
  rsync -av \
    --exclude '.git' \
    --exclude '.gitignore' \
    "$REPO_ROOT"/ "$CONFIG_TARGET"/

  # Ensure helper scripts remain executable after sync.
  find "$CONFIG_TARGET/hypr" "$CONFIG_TARGET/scripts" -type f -name '*.sh' -exec chmod +x {} +
  chmod +x "$CONFIG_TARGET/install/"*.sh 2>/dev/null || true
}

sync_karlos_keys() {
  local ssh_dir="$HOME/.ssh"
  local moved=0

  mkdir -p "$ssh_dir"

  if [[ -f "$REPO_ROOT/karlos.ssh" ]]; then
    install -m 600 -D "$REPO_ROOT/karlos.ssh" "$ssh_dir/karlos"
    moved=1
  elif [[ -f "$HOME/karlos.ssh" ]]; then
    install -m 600 -D "$HOME/karlos.ssh" "$ssh_dir/karlos"
    moved=1
  fi

  if [[ -f "$REPO_ROOT/karlos.ssh.pub" ]]; then
    install -m 644 -D "$REPO_ROOT/karlos.ssh.pub" "$ssh_dir/karlos.pub"
    moved=1
  elif [[ -f "$HOME/karlos.ssh.pub" ]]; then
    install -m 644 -D "$HOME/karlos.ssh.pub" "$ssh_dir/karlos.pub"
    moved=1
  fi

  if [[ $moved -eq 0 ]]; then
    warn "No karlos.ssh / karlos.ssh.pub found; skipping SSH key copy."
  else
    log "karlos SSH material copied into $ssh_dir"
  fi
}

enable_systemd_units() {
  if ! command -v systemctl >/dev/null 2>&1; then
    warn "systemctl not available; skipping systemd setup."
    return
  fi

  systemctl --user daemon-reload

  if [[ ${#TIMERS[@]} -gt 0 ]]; then
    log "Enabling user timers: ${TIMERS[*]}"
    systemctl --user enable --now "${TIMERS[@]}"
  fi

  if [[ ${#SERVICES[@]} -gt 0 ]]; then
    log "Enabling user services: ${SERVICES[*]}"
    systemctl --user enable --now "${SERVICES[@]}"
  fi

  for svc in "${PROTON_SERVICES[@]}"; do
    if systemctl --user enable "$svc" >/dev/null 2>&1; then
      # Start only if the required binary is present.
      if [[ "$svc" == "protonvpn.service" ]] && ! command -v protonvpn >/dev/null 2>&1; then
        warn "protonvpn binary not found; enabled $svc but did not start it."
        continue
      fi
      if [[ "$svc" == "tor.service" ]] && ! command -v tor >/dev/null 2>&1; then
        warn "tor binary not found; enabled $svc but did not start it."
        continue
      fi
      systemctl --user start "$svc" || warn "Failed to start $svc"
    else
      warn "Could not enable $svc"
    fi
  done
}

main() {
  parse_args "$@"

  [[ $INSTALL_PACKAGES -eq 0 ]] || install_pacman_packages
  [[ $INSTALL_PACKAGES -eq 0 ]] || install_aur_packages

  [[ $SYNC_CONFIG -eq 0 ]] || sync_dotfiles
  sync_karlos_keys

  [[ $ENABLE_SYSTEMD -eq 0 ]] || enable_systemd_units

  log "Done."
}

main "$@"
