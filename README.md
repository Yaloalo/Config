# Config (Hyprland + tooling)

## Install command (copy/paste on a new machine)
```
REPO_URL=https://github.com/Yaloalo/Config BRANCH=main bash -lc 'wget -q -O - https://raw.githubusercontent.com/Yaloalo/Config/main/install/bootstrap.sh | bash'
```
If `wget` is missing, swap the middle part with `curl -fsSL ... | bash`.

## Quick setup
- Already cloned to `~/.config`: run `install/install.sh`.
- Flags: `--skip-packages`, `--skip-systemd`, `--skip-sync` as needed.
- AUR helper: expects `yay` or `paru` for AUR packages. ProtonVPN/Tor units start only if binaries exist.
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
- Services: `hyprlock-on-suspend.service`; optional `protonvpn.service` + `tor.service`.
- Installer runs `systemctl --user enable --now` on these; `daemon-reload` included.

## Packages
- Pacman + AUR lists live in `install/install.sh` (edit there, commit, rerun `install.sh --skip-sync` on other machines to pick up new packages).

## Keeping machines in sync
- Edit configs in `~/.config`, then `git add/commit/push`.
- On other machines: `git pull` (and rerun `install.sh --skip-sync` if you changed packages/systemd).
