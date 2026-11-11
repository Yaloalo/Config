//@ pragma AppId org.quickshell
//@ pragma Env QS_NO_RELOAD_POPUP=1

import Quickshell
import Quickshell.Io
import qs.common

ShellRoot {
    Background {}
    Bar {}
    Overlay {}
    Notifications {}

    IpcHandler {
        target: "shell"

        function toggleLauncher() { ShellState.toggle("launcher"); }
        function toggleKeybinds() { ShellState.toggle("keybinds"); }
        function togglePower() { ShellState.toggle("power"); }
        function toggleWifi() { ShellState.toggle("wifi"); }
        function toggleSettings() { ShellState.toggle("settings"); }
        function close() { ShellState.close(); }
        function toggleMotion() { ShellState.toggleMotion(); }
        function toggleBar() { ShellState.toggleBar(); }
        function toggleMode() { ShellState.setMode(Mode.eva ? "star" : "eva"); }
    }
}
