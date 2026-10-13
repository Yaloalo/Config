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
    // Opt-in per field: only the desktop background follows warp mode and CPU heat.
    property bool starModes: false
    // 0..1 CPU heat; when set (>= 0) hotter means faster stars.
    property real heat: -1
    readonly property bool paused: !moving || (preferences?.ecoMode && preferences?.ecoPauseStars) || false
    // Speed multiplier from heat: 0.5x when cool, 4x flat out.
    readonly property real speedTarget: starModes && heat >= 0 ? 0.5 + heat * 3.5 : 1
    readonly property real warpTarget: starModes && !falling && !paused && (preferences?.warpMode ?? false) ? 1 : 0
    // Current values, chased by critically damped springs so neither the warp
    // toggle nor 3 s sensor steps ever jump.
    property real speedScale: 1
    property real speedV: 0
    property real warp: 0
    property real warpV: 0
    readonly property bool settling: Math.abs(speedScale - speedTarget) > 0.001 || Math.abs(warp - warpTarget) > 0.001
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
            readonly property real dx: (root.unit(index, 1) - 0.5) * root.width
            readonly property real dy: (root.unit(index, 2) - 0.5) * root.height
            readonly property real headX: root.falling ? root.unit(index, 1) * root.width : root.width / 2 + dx / depth
            readonly property real headY: root.falling ? ((root.unit(index, 2) + 1 - root.travel * (1 + index % 5)) % 1 + 1) % 1 * root.height
                : root.height / 2 + dy / depth
            // Streak = projected distance between the star now and a little further back in depth.
            readonly property real trail: root.warp > 0
                ? Math.sqrt(dx * dx + dy * dy) * (1 / depth - 1 / (depth + root.warp * 0.45)) : 0
            x: headX - width
            y: headY - height / 2
            width: starSize + trail
            height: starSize
            radius: starSize / 2
            transformOrigin: Item.Right
            rotation: root.warp > 0 ? Math.atan2(dy, dx) * 180 / Math.PI : 0
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 1 - root.warp) }
                GradientStop { position: 1; color: root.tint }
            }
            opacity: root.strength * (0.3 + root.unit(index, 8) * 0.7) * (root.falling ? 1 : fade)
        }
    }
    // Frame-driven so speed changes (warp ramp, sliders, CPU heat) apply immediately.
    // While frozen it keeps ticking only until the streaks have eased out.
    FrameAnimation {
        running: root.animated && root.visible && (!root.paused || root.settling)
        onTriggered: {
            const dt = Math.min(frameTime, 0.1);
            const spring = (x, v, target, k) => {
                v += (k * k * (target - x) - 2 * k * v) * dt;
                x += v * dt;
                return Math.abs(target - x) < 0.001 && Math.abs(v) < 0.001 ? [target, 0] : [x, v];
            };
            // Slower spring for heat so speed-ups feel like a gradual spool-up.
            [root.speedScale, root.speedV] = spring(root.speedScale, root.speedV, root.speedTarget, 1.1);
            [root.warp, root.warpV] = spring(root.warp, root.warpV, root.warpTarget, 2.6);
            root.warp = Math.max(0, Math.min(1, root.warp));
            if (root.paused) return;
            const speed = (root.preferences?.starSpeed ?? 1) * root.speedScale * (1 + root.warp * 11);
            root.travel = ((root.travel - dt * speed / 46.2) % 1 + 1) % 1;
        }
    }
}
