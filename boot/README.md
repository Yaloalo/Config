# Boot chain (star / eva)

Everything before the desktop follows the same mode as the desktop:

| stage | star | eva |
| --- | --- | --- |
| boot menu | nerv-boot, `theme star`: drifting stars, JetBrains Mono, warp jump on boot | nerv-boot, `theme eva`: the original NERV menu |
| splash | plymouth `deepfield` | plymouth `nerv` |
| login | `quickshell/greeter` star face | `quickshell/greeter` NERV console |

## How the mode gets here

`~/.local/state/desktop-mode` holds `star` or `eva`; Settings -> THEME writes it.
`desktop-mode-sync.path` (root) watches that file and runs `desktop-mode-sync`,
which

- sets `theme star|eva` in `/boot/EFI/nerv/nerv.conf`,
- sets `plymouth.splash=deepfield|nerv` on the `options` line of every
  `/boot/loader/entries/*.conf` (both themes are in the initramfs via the
  `plymouth-themes` mkinitcpio hook, so no rebuild is needed),
- writes `/etc/greetd/desktop/mode` for the login screen.

The sync script reads at most 16 bytes of the user-owned file, refuses
symlinks and accepts only `star` or `eva`.

## Files

| path | what |
| --- | --- |
| `nervboot/star-theme.patch` | adds `theme star` to [nervboot](https://codeberg.org/GuillotineMelody/nervboot) (upstream `ba5bc2a`) |
| `nervboot/build.sh` | clones upstream, applies the patch, builds `nerv-boot.efi` into `~/.cache/nervboot` |
| `plymouth/deepfield/` | star splash; `gen-assets.py` re-renders its PNGs |
| `initcpio/plymouth-themes` | mkinitcpio hook adding both splash themes |
| `desktop-mode-sync`, `systemd/` | the root sync script and its path/service units |

Install or update everything with `scripts/desktop-mode-install.sh`
(`--enable` also makes greetd the display manager). Requirements: the
`plymouth` hook in `/etc/mkinitcpio.conf`, systemd-boot files on the ESP, and
the fonts Barlow Condensed SemiBold and Shippori Mincho B1 ExtraBold in
`/usr/local/share/fonts/` (JetBrains Mono comes from `ttf-jetbrains-mono`).

The boot menu entry `NERV` comes first in the firmware boot order; GRUB stays
as a fallback (F12 at the Lenovo logo). Without `plymouth.splash=` (e.g. via
GRUB) the default splash is `nerv`.
