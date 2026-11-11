#!/usr/bin/env bash
# Install the star / eva desktop modes system-wide (run as your user; uses sudo):
#   - boot menu: nerv-boot with the star patch (boot/nervboot)
#   - boot splash: deepfield (star) and nerv (eva) plymouth themes, both in the initramfs
#   - login screen: greetd + quickshell/greeter
#   - desktop-mode-sync: root service that applies ~/.local/state/desktop-mode to all of the above
#
#   desktop-mode-install.sh           install / update, keep the current display manager
#   desktop-mode-install.sh --enable  also make greetd the display manager (next boot)
# Revert the login manager: sudo systemctl disable greetd && sudo systemctl enable sddm
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
mode_file="${XDG_STATE_HOME:-$HOME/.local/state}/desktop-mode"
greeter_dir=/etc/greetd/desktop
greeter_state=/var/lib/desktop-greeter
themes=/usr/share/plymouth/themes

[[ $EUID -ne 0 ]] || { echo "run as your user; sudo is used where needed" >&2; exit 1; }
for font in "Barlow Condensed" "Shippori Mincho B1" "JetBrains Mono"; do
    [[ -n $(fc-list "$font") ]] || { echo "missing font: $font (see boot/README.md)" >&2; exit 1; }
done
grep -qE '^HOOKS=\(.*\bplymouth\b' /etc/mkinitcpio.conf || {
    echo "add the plymouth hook to HOOKS in /etc/mkinitcpio.conf first (see boot/README.md)" >&2
    exit 1
}
mkdir -p "${mode_file%/*}"
[[ -f $mode_file ]] || echo star > "$mode_file"

echo ":: building nerv-boot with the star patch"
efi=$("$repo/boot/nervboot/build.sh")
nerv_src=${efi%/target/*}

echo ":: boot menu"
sudo install -D -m0755 "$efi" /boot/EFI/nerv/nerv-boot.efi

echo ":: plymouth splashes"
sudo install -d "$themes/deepfield" "$themes/nerv"
sudo install -m0644 "$repo"/boot/plymouth/deepfield/{deepfield.plymouth,deepfield.script,*.png} "$themes/deepfield/"
sudo cp -r "$nerv_src/plymouth/theme/." "$themes/nerv/"
# nerv.script asks for "Barlow Condensed, SemiBold"; naming it in the theme file
# makes the plymouth hook bundle that font (Pango needs the trailing comma form).
sudo sed -i '/^Font=/d; s/^ModuleName=script$/&\nFont=Barlow Condensed, SemiBold/' "$themes/nerv/nerv.plymouth"
# nerv stays plymouth's default (it supplies the fonts); the kernel command line picks the theme.
[[ $(plymouth-set-default-theme) == nerv ]] || sudo plymouth-set-default-theme nerv
sudo install -D -m0755 "$repo/boot/initcpio/plymouth-themes" /etc/initcpio/install/plymouth-themes
grep -qE '^HOOKS=\(.*\bplymouth-themes\b' /etc/mkinitcpio.conf \
    || sudo sed -i -E 's/^(HOOKS=\(.*\bplymouth)\b/\1 plymouth-themes/' /etc/mkinitcpio.conf
# mkinitcpio rewrites the image in place when /boot is tight; refuse below 8 MiB.
free=$(df --output=avail -BM /boot | tail -1 | tr -dc 0-9)
(( free >= 8 )) || { echo "only ${free} MiB free on /boot; not rebuilding the initramfs" >&2; exit 1; }
sudo mkinitcpio -P

echo ":: login screen"
sudo rm -rf "$greeter_dir" /etc/greetd/nerv-greeter /var/lib/nerv-greeter
sudo install -d -m0755 "$greeter_dir"
sudo cp -r "$repo/quickshell/common" "$greeter_dir/common"
sudo cp -rP "$repo/quickshell/greeter" "$greeter_dir/greeter"   # keeps greeter/common -> ../common
sudo chmod -R a+rX "$greeter_dir"
# The greeter account's home is /, so Hyprland and Quickshell keep their state here.
sudo install -d -m0750 -o greeter -g greeter "$greeter_state"
if [[ -f /etc/greetd/config.toml && ! -f /etc/greetd/config.toml.pre-desktop ]]; then
    sudo cp -a /etc/greetd/config.toml /etc/greetd/config.toml.pre-desktop
fi
sudo tee /etc/greetd/config.toml >/dev/null <<TOML
# Written by ~/.config/scripts/desktop-mode-install.sh
[terminal]
vt = 1

[default_session]
command = "env HOME=$greeter_state XDG_CACHE_HOME=$greeter_state/cache XDG_STATE_HOME=$greeter_state/state DESKTOP_MODE_FILE=$greeter_dir/mode start-hyprland -- -c $greeter_dir/greeter/hyprland.conf"
user = "greeter"
TOML

echo ":: mode sync service"
sudo install -D -m0755 "$repo/boot/desktop-mode-sync" /usr/local/lib/desktop-mode/desktop-mode-sync
for unit in desktop-mode-sync.path desktop-mode-sync.service; do
    sed "s|@MODE_FILE@|$mode_file|" "$repo/boot/systemd/$unit" | sudo tee "/etc/systemd/system/$unit" >/dev/null
done
sudo systemctl daemon-reload
sudo systemctl enable --now desktop-mode-sync.path
sudo systemctl start desktop-mode-sync.service

if [[ ${1:-} == --enable ]]; then
    sudo systemctl disable sddm.service 2>/dev/null || true
    sudo systemctl enable greetd.service
fi
echo ":: done. Mode: $(cat "$mode_file"). Toggle it in Settings -> THEME."
