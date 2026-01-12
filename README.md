# Config (Hyprland + tooling)

## Install command (copy/paste on a new machine)
- From any shell (works in fish too):
  ```
  env REPO_URL=https://github.com/Yaloalo/Config BRANCH=main bash -lc 'tmp=$(mktemp) && wget -qO "$tmp" https://raw.githubusercontent.com/Yaloalo/Config/main/install/bootstrap.sh && bash "$tmp"'
  ```
  If `wget` is missing, swap it for curl:
  ```
  env REPO_URL=https://github.com/Yaloalo/Config BRANCH=main bash -lc 'tmp=$(mktemp) && curl -fsSL https://raw.githubusercontent.com/Yaloalo/Config/main/install/bootstrap.sh -o "$tmp" && bash "$tmp"'
  ```

## Quick setup
- Already cloned to `~/.config`: run `install/install.sh`.
- Flags: `--skip-packages`, `--skip-systemd`, `--skip-sync` as needed.
- AUR helper: expects `yay` or `paru` for AUR packages.
- Wallpaper: bundled at `~/.config/wallpapers/default.png` and loaded by hyprpaper for all monitors.

## Stack overview
- Hyprland + hyprpaper + hypridle + hyprlock; kanshi for outputs.
- Launchers/notifications: wofi, mako.
- Bar: waybar (minimal network/volume/date/battery).
- Terminals: wezterm (primary), kitty; tmux.
- Editor: Neovim with treesitter/lush UI plugins.
- Shell prompt: starship; zsh config (oh-my-zsh untracked).
- Screenshots/clipboard: grim + slurp + wl-clipboard; hypr screenshot helper.
- Utilities: brightnessctl, playerctl, fastfetch, btop, ripgrep/fd/fzf, nerd font (JetBrains Mono NF).

## Systemd user units
- Timers: `battery-watch.timer`, `battery-watch-critical.timer`, `bedtime.timer`.
- Services: `hyprlock-on-suspend.service`; optional `tor.service` (starts only if `tor` is installed).
- Installer runs `systemctl --user enable --now` on these; `daemon-reload` included.

## Packages
- Pacman + AUR lists live in `install/install.sh` (edit there, commit, rerun `install.sh --skip-sync` on other machines to pick up new packages).

## Keeping machines in sync
- Edit configs in `~/.config`, then `git add/commit/push`.
- On other machines: `git pull` (and rerun `install.sh --skip-sync` if you changed packages/systemd).
