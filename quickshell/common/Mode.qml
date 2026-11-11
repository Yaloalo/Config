pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Desktop theme mode: "star" (deep space) or "eva" (NERV / MAGI).
// One plain-text file is the single source of truth. Hyprland and WezTerm read
// it too, and the root sync service mirrors it to the boot menu, splash and
// login screen (see scripts/desktop-mode-sync).
Singleton {
    id: root
    readonly property string path: Quickshell.env("DESKTOP_MODE_FILE")
        || (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/desktop-mode"
    property string mode: "star"
    readonly property bool eva: mode === "eva"

    function set(next) {
        if (next !== "star" && next !== "eva") return;
        mode = next;
        file.setText(next + "\n");
    }
    function toggle() { set(eva ? "star" : "eva"); }

    FileView {
        id: file
        path: root.path
        blockLoading: true
        watchChanges: true
        printErrors: false
        onLoaded: root.mode = text().trim() === "eva" ? "eva" : "star"
        onFileChanged: reload()
    }
}
