pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import qs.common

// Deep-space login: the desktop's layered star field, a fixed centered clock
// and one glass panel. Approval drops the field into warp before launch.
Item {
    id: root
    property int row: 2
    readonly property real s: Math.min(width / 1920, height / 1080)
    readonly property bool approved: Auth.phase === "approved"
    readonly property bool denied: Auth.phase === "denied"
    readonly property bool busy: Auth.phase === "deliberating"
    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property color ice: "#ffffff"
    readonly property color text: "#f7fbff"
    readonly property color muted: "#8190a5"
    readonly property color outline: "#505050"
    readonly property color danger: "#ff607c"
    readonly property var field: ({ starDensity: 1.5, starSpeed: root.busy ? 3 : 1, warpMode: root.approved })

    Rectangle { anchors.fill: parent; color: "black" }
    SpaceField { anchors.fill: parent; starModes: true; preferences: root.field; starCount: 320; seed: 3; strength: 0.55; tint: root.ice }
    SpaceField { anchors.fill: parent; starModes: true; preferences: root.field; starCount: 96; seed: 47; strength: 0.42; tint: "#dddddd" }

    SystemClock { id: clock; precision: SystemClock.Seconds }
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.24
        spacing: 6 * root.s
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.date, "HH:mm")
            color: root.text
            font.family: root.font
            font.pixelSize: 132 * root.s
            font.weight: Font.Light
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(clock.date, "dddd  dd MMMM").toUpperCase()
            color: root.muted
            font.family: root.font
            font.pixelSize: 16 * root.s
            font.letterSpacing: 4 * root.s
        }
    }

    Rectangle {
        id: panel
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.55
        width: 560 * root.s
        height: column.implicitHeight + 44 * root.s
        radius: 14 * root.s
        color: "#a6000000"
        border.width: 1
        border.color: root.denied ? root.danger : root.approved ? root.ice : root.outline
        Behavior on border.color { ColorAnimation { duration: 200 } }
        clip: true
        SpaceField { anchors.fill: parent; starCount: 18; seed: 81; strength: 0.4; preferences: ({ starDensity: 1 }) }

        Column {
            id: column
            anchors.centerIn: parent
            width: parent.width - 48 * root.s
            spacing: 14 * root.s
            Repeater {
                model: [
                    { label: "PILOT", value: Auth.user.name },
                    { label: "SESSION", value: Auth.session.name }
                ]
                Item {
                    id: line
                    required property var modelData
                    required property int index
                    readonly property bool active: root.row === index
                    width: column.width
                    height: 30 * root.s
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: line.modelData.label
                        color: root.muted
                        font.family: root.font
                        font.pixelSize: 11 * root.s
                        font.letterSpacing: 2 * root.s
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: (line.active ? "‹  " : "") + line.modelData.value + (line.active ? "  ›" : "")
                        color: line.active ? root.ice : root.text
                        font.family: root.font
                        font.pixelSize: 15 * root.s
                    }
                }
            }
            Rectangle { width: column.width; height: 1; color: root.outline }
            Item {
                width: column.width
                height: 34 * root.s
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Auth.phase === "prompt" ? Auth.prompt : "PASSWORD"
                    color: root.row === 2 ? root.ice : root.muted
                    font.family: root.font
                    font.pixelSize: 11 * root.s
                    font.letterSpacing: 2 * root.s
                }
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 7 * root.s
                    readonly property int shown: Math.min(Auth.phase === "deliberating" ? Auth.held : Auth.password.length, 24)
                    Repeater {
                        model: parent.shown
                        Rectangle { width: 6 * root.s; height: width; radius: width; color: root.denied ? root.danger : root.ice }
                    }
                    Rectangle {
                        width: 2 * root.s; height: 18 * root.s
                        color: root.ice
                        visible: root.row === 2 && !root.busy && !root.approved
                        SequentialAnimation on opacity { loops: Animation.Infinite; NumberAnimation { to: 0; duration: 500 } NumberAnimation { to: 1; duration: 500 } }
                    }
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: panel.bottom
        anchors.topMargin: 18 * root.s
        text: root.approved ? "ENGAGING" : root.busy ? "AUTHENTICATING" : Auth.message
        color: root.denied && !Auth.message.startsWith("PRESS AGAIN") ? root.danger : root.muted
        font.family: root.font
        font.pixelSize: 11 * root.s
        font.letterSpacing: 2 * root.s
    }

    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 26 * root.s
        text: "ENTER  log in    ↑↓  select    ←→  change    F11  reboot    F12  power off"
        color: root.muted
        font.family: root.font
        font.pixelSize: 10 * root.s
    }
    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 22 * root.s
        width: chip.implicitWidth + 22 * root.s
        height: 26 * root.s
        radius: 9 * root.s
        color: "#a6000000"
        border.width: 1
        border.color: root.outline
        Text {
            id: chip
            anchors.centerIn: parent
            text: "DEEP FIELD  /  " + Auth.host.toUpperCase()
            color: root.muted
            font.family: root.font
            font.pixelSize: 9 * root.s
            font.letterSpacing: 1.4 * root.s
        }
    }
}
