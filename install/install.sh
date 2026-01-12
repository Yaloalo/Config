#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_TARGET="${XDG_CONFIG_HOME:-$HOME/.config}"
OH_MY_ZSH_REPO=${OH_MY_ZSH_REPO:-"https://github.com/ohmyzsh/ohmyzsh.git"}

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
  zoxide
  direnv
  broot
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
  wezterm-git
  ghcup-hs-bin
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

install_oh_my_zsh() {
  local omz_dir="$CONFIG_TARGET/zsh/oh-my-zsh"

  mkdir -p "$(dirname "$omz_dir")"

  if [[ -d "$omz_dir/.git" ]]; then
    log "Updating Oh My Zsh in $omz_dir"
    git -C "$omz_dir" pull --ff-only || warn "Could not update Oh My Zsh in $omz_dir"
    return
  fi

  if [[ -f "$omz_dir/oh-my-zsh.sh" ]]; then
    log "Oh My Zsh already present in $omz_dir"
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "git missing; cannot install Oh My Zsh into $omz_dir"
    return
  fi

  log "Cloning Oh My Zsh into $omz_dir"
  git clone --depth 1 "$OH_MY_ZSH_REPO" "$omz_dir"
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
    --exclude '.p10k.zsh' \
    "$REPO_ROOT"/ "$CONFIG_TARGET"/

  # Ensure helper scripts remain executable after sync.
  for dir in "$CONFIG_TARGET/hypr" "$CONFIG_TARGET/scripts" "$CONFIG_TARGET/install" "$CONFIG_TARGET/broot"; do
    [[ -d "$dir" ]] || continue
    find "$dir" -type f -name '*.sh' -exec chmod +x {} +
  done
}

ensure_zsh_setup() {
  local zshenv="$HOME/.zshenv"
  local target_rc="$CONFIG_TARGET/zsh/.zshrc"

  if [[ ! -f "$zshenv" ]]; then
    cat >"$zshenv" <<'EOF'
# Managed by Config installer
export ZDOTDIR=$HOME/.config/zsh
export EDITOR=nvim
export QT_SELECT=4
EOF
    log "Created $zshenv to point ZDOTDIR at ~/.config/zsh"
  fi

  if [[ ! -e "$HOME/.zshrc" && -f "$target_rc" ]]; then
    ln -s "$target_rc" "$HOME/.zshrc"
    log "Linked ~/.zshrc -> $target_rc"
  fi

  if [[ -f "$HOME/.p10k.zsh" ]]; then
    mv "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.bak" || true
    log "Moved existing ~/.p10k.zsh to ~/.p10k.zsh.bak to keep starship prompt."
  fi
}

ensure_ghcup() {
  local env_file="$HOME/.ghcup/env"

  if ! command -v ghcup >/dev/null 2>&1; then
    if command -v curl >/dev/null 2>&1; then
      log "Installing ghcup (Haskell toolchain manager)..."
      BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
      BOOTSTRAP_HASKELL_INSTALL_NO_STACK=1 \
      BOOTSTRAP_HASKELL_ADJUST_BASHRC=N \
      BOOTSTRAP_HASKELL_ADJUST_ZSHRC=N \
      curl -fsSL https://get-ghcup.haskell.org | sh || warn "ghcup bootstrap failed; skipping ghcup setup."
    else
      warn "curl missing; cannot bootstrap ghcup."
      return
    fi
  fi

  if command -v ghcup >/dev/null 2>&1; then
    mkdir -p "$HOME/.ghcup"
    ghcup env >"$env_file" || warn "Failed to write $env_file"
    log "ghcup environment written to $env_file"
  fi
}

install_broot_launcher() {
  local launcher="$CONFIG_TARGET/broot/launcher/bash/br"

  if [[ -s "$launcher" ]]; then
    log "broot launcher already present at $launcher"
    return
  fi

  mkdir -p "$(dirname "$launcher")"
  log "Installing broot bash launcher to $launcher"
  cat >"$launcher" <<'EOF'
# This script was automatically generated by the broot program
# More information can be found in https://github.com/Canop/broot
# This function starts broot and executes the command
# it produces, if any.
# It's needed because some shell commands, like `cd`,
# have no useful effect if executed in a subshell.
function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}
EOF
  chmod +x "$launcher"
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
  install_oh_my_zsh
  ensure_zsh_setup
  ensure_ghcup
  install_broot_launcher
  sync_karlos_keys

  [[ $ENABLE_SYSTEMD -eq 0 ]] || enable_systemd_units

  log "Done."
}

main "$@"
