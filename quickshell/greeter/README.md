# greeter

Login screen for greetd in Quickshell, with two faces that follow the desktop
mode (`$DESKTOP_MODE_FILE`, written by `desktop-mode-sync`):

- **star**: the desktop's layered star field, a centered clock and one glass
  panel; approval drops the field into warp before the session starts.
- **eva**: the NERV console shared with the eva lock screen
  (`common/EvaConsole.qml`). On Enter the MAGI vote: MELCHIOR-1, BALTHASAR-2
  and CASPER-3 flip to 承認 one by one; a wrong password is 否決.

Keys: Enter log in, Up/Down/Tab select row, Left/Right or F2/F3 change
pilot/session, Esc clear, F11 reboot, F12 power off (press twice).

## Files

| file | what it does |
| --- | --- |
| `shell.qml` | one window per output; only the primary output (`greeter.json`) takes the keyboard |
| `LoginScreen.qml` | keyboard handling and the face for the current mode |
| `StarLogin.qml` | the star face |
| `Auth.qml` | greetd conversation, MAGI vote, users from /etc/passwd, sessions from /usr/share/wayland-sessions |
| `common/` | symlink to `quickshell/common`: mode, starfield, NERV widgets |
| `greeter.json` | default pilot, session (desktop file name) and primary output |
| `hyprland.conf` | the compositor greetd runs the greeter in |

Sessions are started through the pilot's login shell (`$SHELL -l -c`), like
SDDM's wayland-session script, so `.zshenv`/`.zprofile` still apply.
`SessionCommand.js` quotes the shell and its command argument for greetd's
outer `/bin/sh -c`; passing an ordinary unquoted argv array loses this boundary
and makes the inner shell exit before launching the desktop.

## Preview

    NERV_GREETER_DEMO=1 qs -p ~/.config/quickshell/greeter

Demo mode does not talk to greetd; the password `eva01` is accepted and F12
closes the preview. It shows the face of your current desktop mode.
`NERV_GREETER_SCREEN=<output>` limits it to one output without grabbing the
keyboard; drive it with
`qs ipc -p ~/.config/quickshell/greeter call greeter type|submit|reset`.

## Install

`scripts/desktop-mode-install.sh` (see `boot/README.md`) copies `common/` and
this directory to `/etc/greetd/desktop/` and writes `/etc/greetd/config.toml`.
If the greeter ever fails to start, log in on another VT (Ctrl+Alt+F2) and run
`sudo systemctl disable greetd && sudo systemctl enable sddm`.

## Credits

The NERV look, palette and the textures in `common/assets/` come from
[nervboot](https://codeberg.org/GuillotineMelody/nervboot) by GuillotineMelody.
