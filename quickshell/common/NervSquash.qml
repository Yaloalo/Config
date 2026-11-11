import QtQuick

// Horizontally squashed Mincho, like nerv-boot's display() style.
Item {
    id: root
    property alias text: label.text
    property alias color: label.color
    property real size: 64
    property real squash: 0.68
    implicitWidth: label.implicitWidth * squash
    implicitHeight: label.implicitHeight
    width: implicitWidth
    height: implicitHeight
    Text {
        id: label
        font.family: Nerv.mincho
        font.weight: Font.ExtraBold
        font.pixelSize: root.size
        color: Nerv.white
        transform: Scale { xScale: root.squash }
    }
}
