import QtQuick
import Quickshell

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
    // A single scene graph node replaces thousands of moving Rectangles.
    // The shader projects independently seeded near/mid/far grids.
    ShaderEffect {
        anchors.fill: parent
        fragmentShader: Quickshell.shellPath("../common/shaders/spacefield.frag.qsb")
        property real travel: root.travel
        property real warp: root.warp
        property real fallingMode: root.falling ? 1 : 0
        property real strength: root.strength
        property color tintColor: root.tint
        property vector2d resolution: Qt.vector2d(Math.max(1, width), Math.max(1, height))
        property vector2d grid: {
            const n = Math.max(1, root.starCount * (root.preferences?.starDensity ?? 1.5));
            const aspect = Math.max(0.2, width / Math.max(1, height));
            // Three strata together yield approximately n visible candidates.
            return Qt.vector2d(Math.sqrt(n * aspect) * 0.49, Math.sqrt(n / aspect) * 0.49);
        }
    }
    onPausedChanged: {
        if (paused) {
            warp = 0;
            warpV = 0;
            speedV = 0;
        }
    }
    // Frame-driven so speed changes (warp ramp, sliders, CPU heat) apply immediately.
    // Pausing must stop the frame clock, even if a heat-driven spring was active.
    FrameAnimation {
        running: root.animated && root.visible && !root.paused
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
