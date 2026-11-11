pragma Singleton
import Quickshell
import QtQuick

// Palette and type straight from nerv-boot (src/ui.rs) so boot menu, splash
// and login read as one system.
Singleton {
    readonly property color void_: "#000000"
    readonly property color grid: "#1a0b04"
    readonly property color line: "#5c2508"
    readonly property color amber: "#b35a12"
    readonly property color orange: "#ff7e1a"
    readonly property color red: "#f0141e"
    readonly property color white: "#fff1e2"
    readonly property color green: "#3ce07c"
    readonly property color slot: "#2e1406"     // unlit block / badge background
    readonly property color slotRed: "#3a0608"
    readonly property string sans: "Barlow Condensed"
    readonly property string mincho: "Shippori Mincho B1"
    readonly property string assets: Quickshell.shellPath("common/assets")
}
