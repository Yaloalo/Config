pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Shapes

// Full-screen NERV authentication console shared by the login screen and the
// lock screen. Pure presentation: the owner feeds state in and handles input.
// Layout coordinates are nerv-boot's 1920x1080 grid, scaled per axis.
Item {
    id: root

    // idle | deliberating | prompt | approved | denied
    property string phase: "idle"
    property var votes: ["standby", "standby", "standby"]
    property int typed: 0
    property string message: ""
    property var logLines: []
    property var rows: []           // [{ n, title, sub, key }]
    property int activeRow: -1      // rows.length = the password field
    property string heading: "PILOT AUTHENTICATION"
    property string stage: ""
    property string idleKanji: "認証"
    property string idleStatus: "AWAITING PILOT"
    property string promptLabel: "PASSWORD"
    property var info: []           // [{ k, v }]
    property var hints: []          // [[key, label]]

    readonly property real sx: width / 1920
    readonly property real sy: height / 1080
    readonly property real s: Math.min(sx, sy)
    readonly property real mx: 72 * sx
    readonly property real listRight: 1190 * sx
    readonly property real sideLeft: 1270 * sx
    readonly property real rightEdge: width - mx
    readonly property bool denied: phase === "denied"
    readonly property bool approved: phase === "approved"
    readonly property bool busy: phase === "deliberating"
    readonly property bool onPassword: activeRow === rows.length
    readonly property color accent: denied ? Nerv.red : Nerv.orange
    readonly property string tone: approved ? "approve" : denied ? "deny" : busy ? "busy" : "idle"

    function px(v) { return v * s; }

    Timer { id: blink; property bool on: true; interval: 480; repeat: true; running: root.visible; onTriggered: on = !on }

    // --- backdrop ---------------------------------------------------------------
    Rectangle { anchors.fill: parent; color: Nerv.void_ }
    SpaceField {
        anchors.fill: parent
        starCount: 150
        seed: 11
        strength: 0.45
        tint: root.denied ? Nerv.red : Nerv.orange
        preferences: ({ starDensity: 1, starSpeed: root.approved ? 14 : root.busy ? 4 : 1 })
    }
    Image { anchors.fill: parent; source: Nerv.assets + "/hex.png"; fillMode: Image.Tile; opacity: 0.9 }

    Item {
        id: ui
        anchors.fill: parent
        opacity: 0
        Component.onCompleted: intro.start()
        ParallelAnimation {
            id: intro
            NumberAnimation { target: ui; property: "opacity"; to: 1; duration: 500; easing.type: Easing.OutCubic }
            NumberAnimation { target: rule; property: "width"; from: 0; to: root.rightEdge - root.mx; duration: 750; easing.type: Easing.OutCubic }
        }

        // Hazard stripe; scrolls while the MAGI deliberate or after a rejection.
        Item {
            width: parent.width
            height: 16 * root.sy
            clip: true
            Image {
                width: parent.width + 88
                height: 32
                source: Nerv.assets + (root.denied ? "/hazard-red.png" : "/hazard-orange.png")
                fillMode: Image.Tile
                NumberAnimation on x { from: 0; to: -88; duration: 600; loops: Animation.Infinite; running: root.busy || root.denied }
            }
        }

        NervSquash {
            x: root.mx
            y: -14 * root.sy
            size: root.px(245)
            text: root.approved ? "承認" : root.denied ? "否決" : root.idleKanji
            color: root.denied ? Nerv.red : root.approved ? Nerv.green : Nerv.white
        }

        Column {
            x: 450 * root.sx
            y: 100 * root.sy
            spacing: 6 * root.sy
            NervLabel { text: root.heading; size: root.px(68); color: root.accent; font.letterSpacing: root.px(5) }
            NervLabel { text: root.stage; size: root.px(28) }
            NervLabel {
                size: root.px(28)
                text: root.approved ? "ACCESS GRANTED" : root.denied ? "ACCESS DENIED"
                    : root.busy ? "MAGI DELIBERATING" : root.phase === "prompt" ? "ADDITIONAL VERIFICATION" : root.idleStatus
                color: root.approved ? Nerv.green : root.accent
            }
        }

        SystemClock { id: clock; precision: SystemClock.Seconds }
        NervLabel {
            anchors.right: parent.right
            anchors.rightMargin: root.mx
            y: 92 * root.sy
            size: root.px(118)
            font.letterSpacing: root.px(4)
            font.features: { "tnum": 1 }
            color: Nerv.orange
            text: Qt.formatTime(clock.date, "HH:mm:ss")
        }
        NervLabel {
            anchors.right: parent.right
            anchors.rightMargin: root.mx
            y: 222 * root.sy
            size: root.px(28)
            text: Qt.formatDate(clock.date, "yyyy.MM.dd")
        }

        Item {
            id: rule
            x: root.mx
            y: 302 * root.sy
            width: root.rightEdge - root.mx
            height: 22 * root.sy
            clip: true
            Rectangle { width: parent.width; height: Math.max(2, root.px(3)); color: Nerv.orange }
            Repeater {
                model: 75
                Rectangle {
                    required property int index
                    x: index * 24 * root.sx
                    y: Math.max(2, root.px(3))
                    width: Math.max(1, root.px(2))
                    height: (index % 5 === 0 ? 16 : 7) * root.sy
                    color: index % 5 === 0 ? Nerv.orange : Nerv.amber
                }
            }
        }

        // --- left: entry rows -------------------------------------------------------
        Repeater {
            model: root.rows
            Item {
                id: entry
                required property var modelData
                required property int index
                readonly property bool active: root.activeRow === index
                x: root.mx
                y: (352 + index * 94) * root.sy
                width: root.listRight - root.mx
                height: 84 * root.s
                Rectangle { visible: entry.active; x: -30 * root.sx; width: 14 * root.sx; height: parent.height; color: Nerv.red }
                Rectangle {
                    width: 78 * root.sx; height: parent.height
                    color: entry.active ? "transparent" : Nerv.slot
                    NervLabel { anchors.centerIn: parent; text: entry.modelData.n; size: root.px(46); color: entry.active ? Nerv.orange : Nerv.amber }
                }
                Shape {
                    x: 78 * root.sx
                    width: parent.width - x; height: parent.height
                    visible: entry.active
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeWidth: -1
                        fillColor: Nerv.orange
                        startX: 0; startY: 0
                        PathLine { x: entry.width - 78 * root.sx - 26 * root.s; y: 0 }
                        PathLine { x: entry.width - 78 * root.sx; y: 26 * root.s }
                        PathLine { x: entry.width - 78 * root.sx; y: entry.height }
                        PathLine { x: 0; y: entry.height }
                    }
                }
                Rectangle {
                    visible: !entry.active
                    x: 78 * root.sx; y: parent.height - height
                    width: parent.width - x; height: Math.max(1, root.px(2))
                    color: Nerv.line
                }
                NervSquash {
                    x: 106 * root.sx
                    anchors.verticalCenter: parent.verticalCenter
                    size: root.px(80)
                    text: entry.modelData.title
                    color: entry.active ? Nerv.void_ : Nerv.white
                }
                NervLabel {
                    anchors.right: parent.right
                    anchors.rightMargin: 40 * root.sx
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10 * root.sy
                    size: root.px(28)
                    text: entry.modelData.sub + (entry.modelData.key ? "   ·   " + entry.modelData.key : "")
                    color: entry.active ? Nerv.void_ : Nerv.amber
                    elide: Text.ElideLeft
                    width: Math.min(implicitWidth, parent.width * 0.45)
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        // --- left: password blocks ------------------------------------------------------
        NervLabel {
            x: root.mx
            y: 568 * root.sy
            size: root.px(28)
            text: root.promptLabel
            color: root.onPassword ? root.accent : Nerv.amber
        }
        Row {
            id: blocks
            x: root.mx
            y: 612 * root.sy
            spacing: 8 * root.sx
            readonly property int count: 24
            Repeater {
                model: blocks.count
                Rectangle {
                    required property int index
                    readonly property bool filled: index < Math.min(root.typed, blocks.count - 1)
                    readonly property bool cursor: index === Math.min(root.typed, blocks.count - 1) && root.onPassword
                    width: 38 * root.sx
                    height: 62 * root.sy
                    color: root.approved ? (index < 3 ? Nerv.green : Nerv.slot)
                        : root.denied ? (index % 2 ? Nerv.red : Nerv.slotRed)
                        : filled ? Nerv.orange
                        : cursor ? (blink.on ? Nerv.red : Nerv.slot)
                        : Nerv.slot
                }
            }
        }
        NervLabel {
            x: root.mx
            y: 696 * root.sy
            width: root.listRight - root.mx
            size: root.px(28)
            elide: Text.ElideRight
            text: root.message
            color: root.message.startsWith("PRESS AGAIN") ? Nerv.orange : Nerv.red
        }

        // --- left: log panel ------------------------------------------------------------
        Item {
            x: root.mx
            y: 790 * root.sy
            width: root.listRight - root.mx
            height: 170 * root.sy
            NervBrackets { anchors.fill: parent; arm: root.px(24); thick: Math.max(2, root.px(3)) }
            Column {
                x: 26 * root.sx
                y: 22 * root.sy
                spacing: 4 * root.sy
                Repeater {
                    model: root.logLines
                    NervLabel { required property string modelData; text: modelData; size: root.px(24); color: Nerv.white; font.letterSpacing: 0 }
                }
            }
        }

        // --- right: MAGI, lamps, telemetry, status --------------------------------------------
        MagiPanel {
            x: root.sideLeft
            y: 352 * root.sy
            width: root.rightEdge - root.sideLeft
            height: 262 * root.sy
            unit: root.s
            votes: root.votes
            blink: blink.on
        }
        LampBank {
            x: root.sideLeft
            y: 640 * root.sy
            tone: root.tone
            cellWidth: 34 * root.sx
            cellHeight: 14 * root.sy
            columnSpacing: (root.rightEdge - root.sideLeft - 14 * 34 * root.sx) / 13
            rowSpacing: 8 * root.sy
        }
        Column {
            x: root.sideLeft
            y: 752 * root.sy
            spacing: 4 * root.sy
            Repeater {
                model: root.info
                Row {
                    required property var modelData
                    NervLabel { width: 150 * root.sx; text: modelData.k; size: root.px(24) }
                    NervLabel { text: modelData.v; size: root.px(24); color: Nerv.white; font.letterSpacing: 0 }
                }
            }
        }
        Rectangle {
            x: root.sideLeft
            y: 905 * root.sy
            width: root.rightEdge - root.sideLeft
            height: 94 * root.sy
            color: "transparent"
            border.color: root.approved ? Nerv.green : root.accent
            border.width: Math.max(2, root.px(3))
            NervSquash {
                x: 28 * root.sx
                anchors.verticalCenter: parent.verticalCenter
                size: root.px(64)
                squash: 0.7
                text: root.approved ? "承認" : root.denied ? "否決" : root.busy ? "審議" : "待機"
                color: root.approved ? Nerv.green : root.accent
            }
            NervLabel {
                x: 146 * root.sx
                anchors.verticalCenter: parent.verticalCenter
                size: root.px(32)
                text: root.approved ? "UNANIMOUS  /  ACCESS" : root.denied ? "PILOT REJECTED" : root.busy ? "VOTE IN PROGRESS" : root.idleStatus
                color: root.approved ? Nerv.green : root.accent
            }
        }

        Row {
            x: root.mx
            y: 1016 * root.sy
            spacing: 36 * root.sx
            Repeater {
                model: root.hints
                Row {
                    required property var modelData
                    spacing: 10 * root.sx
                    NervLabel { text: modelData[0]; size: root.px(24); color: Nerv.orange }
                    NervLabel { text: modelData[1]; size: root.px(24) }
                }
            }
        }
    }

    // CRT scanlines over everything.
    Image { anchors.fill: parent; source: Nerv.assets + "/scan.png"; fillMode: Image.Tile; opacity: 0.55 }
}
