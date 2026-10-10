import QtQuick

Item {
    id: root
    property int starCount: 180
    property real seed: 0
    property real strength: 0.6
    property color tint: "white"
    property bool animated: true
    property bool falling: false
    property var preferences: null
    property bool moving: true
    property real travel: 0
    clip: true
    function unit(i, salt) {
        const n = Math.sin((i + 1) * (91.713 + seed * 7.31) + salt * 37.719) * 43758.5453;
        return n - Math.floor(n);
    }
    Repeater {
        model: Math.round(root.starCount * (root.preferences?.starDensity ?? 1.5))
        Rectangle {
            required property int index
            readonly property real depth: 0.15 + ((root.unit(index, 3) + root.travel) % 1) * 1.85
            readonly property real fade: Math.min(1, (depth - 0.15) * 4) * Math.min(1, (2 - depth) * 3)
            readonly property real starSize: (0.6 + root.unit(index, 4) * 1.1) / Math.sqrt(depth)
            x: root.falling ? root.unit(index, 1) * root.width
                : root.width / 2 + (root.unit(index, 1) - 0.5) * root.width / depth
            y: root.falling ? ((root.unit(index, 2) + 1 - root.travel * (1 + index % 5)) % 1 + 1) % 1 * root.height
                : root.height / 2 + (root.unit(index, 2) - 0.5) * root.height / depth
            width: starSize
            height: starSize
            radius: starSize
            color: root.tint
            opacity: root.strength * (0.3 + root.unit(index, 8) * 0.7) * (root.falling ? 1 : fade)
        }
    }
    NumberAnimation on travel {
        from: 1; to: 0; duration: 46200 / (root.preferences?.starSpeed ?? 1)
        loops: Animation.Infinite
        running: root.animated && root.visible
        paused: !root.moving || (root.preferences?.ecoMode && root.preferences?.ecoPauseStars) || false
    }
}
