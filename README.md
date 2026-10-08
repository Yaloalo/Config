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
  Requires `git` on the target machine (bootstrap clones the repo before running the installer).

## Quick setup
- Already cloned to `~/.config`: run `install/install.sh`.
- Flags: `--skip-packages`, `--skip-systemd`, `--skip-sync` as needed.
- AUR helper: expects `yay` or `paru` for AUR packages (uses `wezterm-git` from AUR; repo `wezterm` is not pulled).
- Desktop shell: Quickshell owns the bar, wallpaper, launcher, Wi-Fi UI, notifications, power menu, and shortcut atlas.
- Log out and back in once after upgrading from Hyprland's old `.conf` format; Lua is preferred automatically on the next session.
- Upload helper: `scripts/upload.sh "message"` will git add/commit/push your config changes.

## Stack overview
- Hyprland 0.55+ native Lua config, split by responsibility under `hypr/config/`.
- Quickshell black-hole shell: bar, animated wallpaper, launcher, native Wi-Fi, notifications, and power menu.
- Displays: `nwg-displays` provides drag-and-drop placement plus mirror/extend controls.
- Terminals: wezterm (primary), kitty; tmux.
- Editor: slim Neovim 0.12 setup with one clear job per plugin.
- Shell prompt: starship; zsh config (oh-my-zsh untracked).
- Screenshots/clipboard: grim + slurp + wl-clipboard; hypr screenshot helper.
- Utilities: brightnessctl, playerctl, fastfetch, btop, ripgrep/fd/fzf, nerd font (JetBrains Mono NF).

## Desktop controls

- `Super+R`: application launcher
- Click Wi-Fi in the bar: graphical network chooser
- Scroll/click volume in the bar: adjust/mute audio
- `Super+M`: drag, mirror, extend, and arrange displays
- `Super+F1`: searchable shortcut atlas for Hyprland, WezTerm, Neovim, Yazi, and Zsh
- `Super+B`: pause/resume the desktop black-hole motion
- `Super+I`: power menu

## Systemd user units
- Timers: `battery-watch.timer`, `battery-watch-critical.timer`, `bedtime.timer`.
- Services: `hyprlock-on-suspend.service`; optional `tor.service` (starts only if `tor` is installed).
- Installer runs `systemctl --user enable --now` on these; `daemon-reload` included.

## Packages
- Pacman + AUR lists live in `install/install.sh` (edit there, commit, rerun `install.sh --skip-sync` on other machines to pick up new packages).

## Keeping machines in sync
- Edit configs in `~/.config`, then `scripts/upload.sh "message"` (or `git add/commit/push`).
- On other machines: `git pull` (and rerun `install.sh --skip-sync` if you changed packages/systemd).
