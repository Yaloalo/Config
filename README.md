# Config (Hyprland + tooling)

## Quick setup
- Fresh box: run `~/.config/install/bootstrap.sh` (wget grabs the repo, runs installer). If already cloned to `~/.config`, run `install/install.sh`.
- Flags: `--skip-packages`, `--skip-systemd`, `--skip-sync` as needed.
- AUR helper: expects `yay` or `paru` for AUR packages. ProtonVPN/Tor units start only if binaries exist.
- Wallpaper: bundled at `~/.config/wallpapers/default.png` and loaded by hyprpaper for all monitors.
- SSH: if `karlos.ssh`/`.pub` is present (repo or `$HOME`), installer copies to `~/.ssh` with correct perms (not tracked).

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
- Services: `hyprlock-on-suspend.service`; optional `protonvpn.service` + `tor.service`.
- Installer runs `systemctl --user enable --now` on these; `daemon-reload` included.

## Packages
- Pacman + AUR lists live in `install/install.sh` (edit there, commit, rerun `install.sh --skip-sync` on other machines to pick up new packages).

## Keeping machines in sync
- Edit configs in `~/.config`, then `git add/commit/push`.
- On other machines: `git pull` (and rerun `install.sh --skip-sync` if you changed packages/systemd).
