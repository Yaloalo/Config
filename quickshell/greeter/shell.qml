pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.common

// Login screen for greetd, star or eva face depending on the desktop mode.
// Run by hyprland.conf under greetd; see README.md. NERV_GREETER_DEMO=1
// previews it without greetd.
ShellRoot {
    Variants {
        // NERV_GREETER_SCREEN limits the preview to one output.
        model: Quickshell.screens.filter(s => !Quickshell.env("NERV_GREETER_SCREEN") || s.name === Quickshell.env("NERV_GREETER_SCREEN"))
        PanelWindow {
            id: window
            required property var modelData
            readonly property bool primary: {
                const names = Quickshell.screens.map(s => s.name);
                const want = Auth.settings.primary;
                return (names.includes(want) ? want : names[0]) === modelData.name || !!Quickshell.env("NERV_GREETER_SCREEN");
            }
            screen: modelData
            color: "black"
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "nerv-greeter"
            WlrLayershell.layer: WlrLayer.Overlay
            // A preview on a single output never grabs the keyboard; drive it with `qs ipc`.
            WlrLayershell.keyboardFocus: primary && !Quickshell.env("NERV_GREETER_SCREEN") ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            LoginScreen { anchors.fill: parent; primary: window.primary }
        }
    }
}
