#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_TARGET="${XDG_CONFIG_HOME:-$HOME/.config}"
OH_MY_ZSH_REPO=${OH_MY_ZSH_REPO:-"https://github.com/ohmyzsh/ohmyzsh.git"}
WORDLIST_REPO=${WORDLIST_REPO:-"https://github.com/kkrypt0nn/wordlists"}
HACKING_DIR=${HACKING_DIR:-"$HOME/hacking"}

INSTALL_PACKAGES=1
ENABLE_SYSTEMD=1
SYNC_CONFIG=1
ENABLE_SYSTEM_SERVICES=1
ENABLE_CHSH=1

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
  tree-sitter-cli
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
  greetd
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
  tuigreet
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
  --skip-system-services  Do not enable system-level services
  --skip-shell      Do not change the login shell to zsh
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
      --skip-system-services) ENABLE_SYSTEM_SERVICES=0 ;;
      --skip-shell)    ENABLE_CHSH=0 ;;
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

install_blackarch() {
  if ! command -v pacman >/dev/null 2>&1; then
    warn "pacman not found; skipping BlackArch setup."
    return
  fi

  if grep -qs "^[[:space:]]*\\[blackarch\\]" /etc/pacman.conf; then
    log "BlackArch repo already configured."
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl missing; cannot run BlackArch strap script."
    return
  fi

  log "Installing BlackArch repo via strap script..."
  curl -fsS https://blackarch.org/strap.sh | sudo bash || warn "BlackArch strap script failed."
}

install_wordlists() {
  mkdir -p "$HACKING_DIR"

  if [[ -d "$HACKING_DIR/wordlists/.git" ]]; then
    log "Updating wordlists in $HACKING_DIR/wordlists"
    git -C "$HACKING_DIR/wordlists" pull --ff-only || warn "Could not update wordlists repo."
    return
  fi

  if [[ -d "$HACKING_DIR/wordlists" ]]; then
    log "Wordlists directory already present at $HACKING_DIR/wordlists"
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "git missing; cannot clone wordlists into $HACKING_DIR"
    return
  fi

  log "Cloning wordlists into $HACKING_DIR/wordlists"
  git clone --depth 1 "$WORDLIST_REPO" "$HACKING_DIR/wordlists"
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

install_omz_plugin() {
  local name="${1:-}" repo="${2:-}"
  if [[ -z "$name" || -z "$repo" ]]; then
    warn "install_omz_plugin missing name or repo; skipping."
    return
  fi
  local target="$CONFIG_TARGET/zsh/oh-my-zsh/custom/plugins/$name"
  local plugin_file_a="$target/$name.plugin.zsh"
  local plugin_file_b="$target/$name.zsh"

  mkdir -p "$(dirname "$target")"

  if [[ -d "$target/.git" ]]; then
    log "Updating Oh My Zsh plugin $name"
    git -C "$target" pull --ff-only || warn "Could not update $name plugin"
    return
  fi

  if [[ -d "$target" ]]; then
    if [[ -z "$(ls -A "$target")" ]]; then
      log "Removing empty Oh My Zsh plugin dir $name"
      rmdir "$target" || true
    elif [[ -f "$plugin_file_a" || -f "$plugin_file_b" ]]; then
      log "Oh My Zsh plugin $name already present"
      return
    else
      log "Oh My Zsh plugin $name missing expected files; reinstalling"
      rm -rf "$target"
    fi
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "git missing; cannot install Oh My Zsh plugin $name"
    return
  fi

  log "Cloning Oh My Zsh plugin $name"
  git clone --depth 1 "$repo" "$target"
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

ensure_zsh_shell() {
  local desired_shell current_shell

  if ! command -v zsh >/dev/null 2>&1; then
    warn "zsh not installed; cannot change login shell."
    return
  fi

  desired_shell="$(command -v zsh)"
  if [[ -f /etc/shells ]] && ! grep -qx "$desired_shell" /etc/shells; then
    warn "zsh shell $desired_shell not listed in /etc/shells; skipping chsh."
    return
  fi

  if command -v getent >/dev/null 2>&1; then
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
  else
    current_shell="${SHELL:-}"
  fi

  if [[ -n "$current_shell" && "$current_shell" == "$desired_shell" ]]; then
    log "Login shell already set to zsh ($desired_shell)"
    return
  fi

  if chsh -s "$desired_shell" "$USER"; then
    log "Changed login shell to $desired_shell"
  else
    warn "Failed to change login shell; run: chsh -s $desired_shell"
  fi
}

ensure_greetd_config() {
  local config="/etc/greetd/config.toml"
  local tmp_file

  if [[ -f "$config" ]]; then
    log "greetd config already present at $config"
    return
  fi

  if ! command -v tuigreet >/dev/null 2>&1; then
    warn "tuigreet not installed; skipping greetd config."
    return
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    warn "sudo not available; cannot write $config."
    return
  fi

  tmp_file="$(mktemp)"
  cat >"$tmp_file" <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd Hyprland"
user = "greeter"
EOF

  if sudo install -Dm644 "$tmp_file" "$config"; then
    log "Installed greetd config at $config"
  else
    warn "Failed to write $config"
  fi
  rm -f "$tmp_file"
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

enable_system_services() {
  local svc

  if ! command -v systemctl >/dev/null 2>&1; then
    warn "systemctl not available; skipping system service setup."
    return
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    warn "sudo not available; cannot enable system services."
    return
  fi

  for svc in NetworkManager.service pipewire.service pipewire-pulse.service wireplumber.service greetd.service; do
    if systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -qx "$svc"; then
      log "Enabling system service: $svc"
      sudo systemctl enable --now "$svc" || warn "Failed to enable $svc"
    else
      warn "System service $svc not found; skipping."
    fi
  done
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
  [[ $INSTALL_PACKAGES -eq 0 ]] || install_blackarch

  [[ $SYNC_CONFIG -eq 0 ]] || sync_dotfiles
  install_oh_my_zsh
  install_omz_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
  install_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
  ensure_zsh_setup
  [[ $ENABLE_CHSH -eq 0 ]] || ensure_zsh_shell
  ensure_ghcup
  install_broot_launcher
  install_wordlists

  ensure_greetd_config
  [[ $ENABLE_SYSTEM_SERVICES -eq 0 ]] || enable_system_services
  [[ $ENABLE_SYSTEMD -eq 0 ]] || enable_systemd_units

  log "Done."
}

main "$@"
