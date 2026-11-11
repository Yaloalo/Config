import QtQuick

// Four corner brackets framing a panel.
Item {
    id: root
    property color color: Nerv.amber
    property real arm: 24
    property real thick: 3
    Repeater {
        model: 4
        Item {
            required property int index
            readonly property bool r: index % 2 === 1
            readonly property bool b: index > 1
            x: r ? root.width - root.arm : 0
            y: b ? root.height - root.arm : 0
            width: root.arm; height: root.arm
            Rectangle { width: parent.width; height: root.thick; y: parent.b ? parent.height - height : 0; color: root.color }
            Rectangle { width: root.thick; height: parent.height; x: parent.r ? parent.width - width : 0; color: root.color }
        }
    }
}
