import QtQuick

// Barlow Condensed caps, the workhorse NERV label. `size` is in final pixels.
Text {
    property real size: 28
    font.family: Nerv.sans
    font.weight: Font.DemiBold
    font.pixelSize: size
    font.letterSpacing: size * 0.08
    color: Nerv.amber
}
