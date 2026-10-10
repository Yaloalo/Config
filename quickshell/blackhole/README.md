# Space desktop

Black glass, a white layered star field, and a fixed centered clock. The old
black-hole assets are retained but are not loaded by the desktop.

## Shortcuts

- Super R: applications (arrows select; Enter opens the highlighted result).
- Super G: shortcut guide (H/J/K/L or arrows; `/` searches; Escape backs out).
- Super comma: settings. Super Shift Escape: session/power.
- Super Escape: manual lock. Type the login password and press Enter. The lock
  intentionally shows no input, errors, dots, clock, or authentication feedback.
  Escape clears the invisible input. Failed authentication stays locked.
- Super T/B/O/N: terminal/browser/files/Neovim.
- Super F: fullscreen; Super Shift F: floating; Super Shift C: close.
- Super H/J/K/L: focus; add Shift to swap. E/W/Q keep their scratchpad/laptop/
  external-workspace meanings; Shift sends a window there.
- Super Pause: freeze/resume stars.
- WezTerm: Ctrl Shift T/W creates a tab/closes a pane; S/D stacks/divides panes;
  H/J/K/L focuses panes; O changes opacity; E edits scrollback; F searches;
  P opens the command palette. Ctrl PageUp/PageDown switches tabs, adding Shift
  reorders. Ctrl =/-/0 changes/resets font size.
- Neovim: Space W groups window actions (S/V split, Q close, H/J/K/L focus,
  W save). Ctrl S saves. Space U O changes opacity. Existing plugin shortcuts
  stay under their search, LSP, Harpoon, compiler and other mnemonic groups.

## Settings and extensions

The sliders button at the top right opens settings. `SettingsPage.qml` contains
data-driven control and device-action lists. Add a control there and a property
to `Preferences.qml` plus its `fields` list to persist it in `preferences.json`.
`SpaceField.qml` is independent of the desktop shell so the lock process can use
it without loading desktop panels or services.

Eco can freeze stars, disable blur/window animations and cap brightness. The
previous brightness and effect states are saved in the user runtime directory
and restored on exit. CPU power-saver is used only when `powerprofilesctl` is
installed; otherwise the panel reports that it is unavailable. Bluetooth and
Wi-Fi are never silently disabled. Star speed 1 includes the requested 10%
longer animation cycle; density and speed are independently adjustable.

The persistent window border is monochrome. `FocusComet.qml` draws a separate
input-transparent yellow trail for one 1.05-second lap, fading to zero. It is
disabled in eco mode or with the focus-trail setting.

Automatic locking is disabled; closing the lid suspends using the detected
`Lid Switch` binding. Suspending does not lock unless you manually lock first.
The locker uses the existing `hyprlock` PAM policy and Wayland session-lock
protocol, in a separate Quickshell process. For a nonlocking visual preview:

```sh
INFINITY_LOCK_PREVIEW=1 qs -p ~/.config/quickshell/blackhole/lock.qml
```

The built-in display uses scale 1.333333 (the compositor-supported step below
the old 1.6), which also reduces Firefox and other application chrome.
Displays / scale / mirror in Settings opens the existing display arranger.
