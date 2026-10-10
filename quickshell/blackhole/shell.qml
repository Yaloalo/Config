//@ pragma AppId org.quickshell
//@ pragma Env QS_NO_RELOAD_POPUP=1

import Quickshell
import Quickshell.Io

ShellRoot {
    Background {}
    Bar {}
    Overlay {}
    Notifications {}
    FocusComet {}

    IpcHandler {
        target: "shell"

        function toggleLauncher() { ShellState.toggle("launcher"); }
        function toggleKeybinds() { ShellState.toggle("keybinds"); }
        function togglePower() { ShellState.toggle("power"); }
        function toggleWifi() { ShellState.toggle("wifi"); }
        function toggleSettings() { ShellState.toggle("settings"); }
        function close() { ShellState.close(); }
        function toggleMotion() { ShellState.motionEnabled = !ShellState.motionEnabled; }
    }
}
