import QtQuick

// Grid of blinking status lamps with no meaning whatsoever, as is tradition.
// tone: "idle" | "busy" | "approve" | "deny"
Grid {
    id: root
    property string tone: "idle"
    property real cellWidth: 34
    property real cellHeight: 14
    property int count: columns * 4
    property int tick: 0
    columns: 14
    Timer { interval: root.tone === "busy" ? 70 : 180; repeat: true; running: root.visible; onTriggered: root.tick++ }
    Repeater {
        model: root.count
        Rectangle {
            required property int index
            readonly property real r: {
                const n = Math.sin((index + 1) * 12.9898 + Math.floor((root.tick + index * 7) / (3 + index % 5)) * 78.233) * 43758.5453;
                return n - Math.floor(n);
            }
            width: root.cellWidth
            height: root.cellHeight
            color: root.tone === "approve" ? (r > 0.25 ? Nerv.green : Nerv.slot)
                : root.tone === "deny" ? (r > 0.3 ? Nerv.red : Nerv.slotRed)
                : r > 0.97 ? Nerv.green : r > 0.92 ? Nerv.red : r > 0.6 ? Nerv.orange : Nerv.slot
        }
    }
}
