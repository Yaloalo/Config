import QtQuick

// The three MAGI units in their classic arrangement: BALTHASAR on top, CASPER
// left, MELCHIOR right. votes[i] per unit: standby | deliberating | approve | deny
Item {
    id: root
    property var votes: ["standby", "standby", "standby"]
    property bool blink: true
    property real unit: 1           // pixel scale for type and strokes
    readonly property real unitW: width * 0.47
    readonly property real unitH: height * 0.46

    Column {
        NervLabel { text: "MAGI"; size: 40 * root.unit; color: Nerv.orange; font.letterSpacing: 8 * root.unit }
        NervLabel { text: "3 UNITS"; size: 22 * root.unit }
    }
    Repeater {
        model: [
            { name: "MELCHIOR · 1", vote: 0, px: 1, py: 1 },
            { name: "BALTHASAR · 2", vote: 1, px: 0.5, py: 0 },
            { name: "CASPER · 3", vote: 2, px: 0, py: 1 }
        ]
        Rectangle {
            id: cell
            required property var modelData
            readonly property string vote: root.votes[modelData.vote]
            readonly property bool solid: vote === "approve" || vote === "deny"
            readonly property color tone: vote === "approve" ? Nerv.green : vote === "deny" ? Nerv.red : Nerv.orange
            x: modelData.px * (root.width - root.unitW)
            y: modelData.py * (root.height - root.unitH)
            width: root.unitW
            height: root.unitH
            color: solid ? tone : "#c0000000"
            border.color: vote === "standby" ? Nerv.line : tone
            border.width: Math.max(2, 3 * root.unit)
            NervLabel {
                x: 16 * root.unit; y: 8 * root.unit
                size: 22 * root.unit
                text: cell.modelData.name
                color: cell.solid ? Nerv.void_ : Nerv.amber
            }
            NervSquash {
                anchors.right: parent.right
                anchors.rightMargin: 16 * root.unit
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2 * root.unit
                size: 64 * root.unit
                squash: 0.85
                text: cell.vote === "approve" ? "承認" : cell.vote === "deny" ? "否決" : cell.vote === "deliberating" ? "審議" : "待機"
                color: cell.solid ? Nerv.void_
                    : cell.vote === "deliberating" ? (root.blink ? Nerv.orange : Nerv.amber) : Nerv.line
            }
        }
    }
}
