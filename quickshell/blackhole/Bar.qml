pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property var wifiDevice: Networking.devices.values.find(device => device.type === DeviceType.Wifi) ?? null
    readonly property var activeNetwork: wifiDevice?.networks.values.find(network => network.connected) ?? null

    function setVolume(value) {
        if (sink?.ready && sink.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1, value));
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    PwObjectTracker { objects: [root.sink] }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            required property var modelData
            readonly property var hyprMonitor: Hyprland.monitorFor(modelData)
            readonly property var localWorkspaces: Hyprland.workspaces.values
                .filter(workspace => workspace.id > 0
                    && workspace.id < 10
                    && workspace.monitor === hyprMonitor)
                .sort((left, right) => left.id - right.id)
            readonly property bool terminalVisible: Hyprland.workspaces.values
                .some(workspace => workspace.name === "special:term"
                    && workspace.active
                    && workspace.monitor === hyprMonitor)

            screen: modelData
            color: "transparent"
            implicitHeight: 42
            exclusiveZone: 42

            anchors { top: true; left: true; right: true }
            WlrLayershell.namespace: "infinity-shell"

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.topMargin: 5
                anchors.bottomMargin: 3
                radius: 12
                color: Theme.surface
                border.width: 1
                border.color: Theme.outline

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 7

                    // Screen identity replaces the old mascot and is unique per bar.
                    Rectangle {
                        implicitWidth: screenText.implicitWidth + 18
                        implicitHeight: 25
                        radius: 8
                        color: window.hyprMonitor?.focused ? Theme.blueSoft : Theme.panel
                        border.width: 1
                        border.color: window.hyprMonitor?.focused ? Theme.blue : Theme.outline

                        Text {
                            id: screenText
                            anchors.centerIn: parent
                            text: (window.hyprMonitor?.name ?? window.modelData.name)
                                + "  /  " + (window.hyprMonitor?.activeWorkspace?.name ?? "—")
                            color: window.hyprMonitor?.focused ? Theme.ice : Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 0.5
                        }
                    }

                    Rectangle {
                        implicitWidth: workspaceStrip.implicitWidth + 8
                        implicitHeight: 27
                        radius: 9
                        color: Theme.panel
                        border.width: 1
                        border.color: Theme.outline

                        RowLayout {
                            id: workspaceStrip
                            anchors.centerIn: parent
                            spacing: 2

                            Repeater {
                                model: window.localWorkspaces

                                Rectangle {
                                    id: workspace
                                    required property var modelData
                                    readonly property bool active: modelData.active
                                    implicitWidth: active ? 25 : 19
                                    implicitHeight: 21
                                    radius: 7
                                    color: active ? Theme.ice : workspaceHover.hovered ? Theme.surfaceHigh : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: workspace.modelData.id
                                        color: workspace.active ? Theme.voidBlack : Theme.muted
                                        font.family: Theme.font
                                        font.pixelSize: 9
                                        font.bold: workspace.active
                                    }

                                    Behavior on implicitWidth { NumberAnimation { duration: 120 } }
                                    HoverHandler { id: workspaceHover }
                                    TapHandler {
                                        onTapped: Hyprland.dispatch("hl.dsp.focus({ workspace = "
                                            + workspace.modelData.id + " })")
                                    }
                                }
                            }

                            Repeater {
                                model: [
                                    { label: "E", target: "special:term", active: window.terminalVisible },
                                    { label: "W", target: "10", active: window.hyprMonitor?.activeWorkspace?.id === 10 },
                                    { label: "Q", target: "11", active: window.hyprMonitor?.activeWorkspace?.id === 11 }
                                ]

                                Rectangle {
                                    id: namedWorkspace
                                    required property var modelData
                                    implicitWidth: 21
                                    implicitHeight: 21
                                    radius: 7
                                    color: modelData.active ? Theme.blue : namedHover.hovered ? Theme.surfaceHigh : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: namedWorkspace.modelData.label
                                        color: namedWorkspace.modelData.active ? Theme.voidBlack : Theme.muted
                                        font.family: Theme.font
                                        font.pixelSize: 9
                                        font.bold: true
                                    }

                                    HoverHandler { id: namedHover }
                                    TapHandler {
                                        onTapped: Hyprland.dispatch(namedWorkspace.modelData.label === "E"
                                            ? "hl.dsp.workspace.toggle_special(\"term\")"
                                            : "hl.dsp.focus({ workspace = " + namedWorkspace.modelData.target + " })")
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "INFINITY  //  " + Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.0
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 3

                        Repeater {
                            model: SystemTray.items

                            Image {
                                id: trayIcon
                                required property var modelData
                                source: modelData.icon
                                sourceSize.width: 15
                                sourceSize.height: 15
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                fillMode: Image.PreserveAspectFit

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: event => {
                                        if (event.button === Qt.RightButton && trayIcon.modelData.hasMenu)
                                            trayIcon.modelData.display(window, trayIcon.x, trayIcon.y + trayIcon.height);
                                        else
                                            trayIcon.modelData.activate();
                                    }
                                }
                            }
                        }

                        Rectangle {
                            implicitWidth: 132
                            implicitHeight: 25
                            radius: 8
                            color: wifiHover.hovered ? Theme.surfaceHigh : "transparent"

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 9
                                anchors.rightMargin: 9
                                verticalAlignment: Text.AlignVCenter
                                text: root.activeNetwork ? "WLAN  ·  " + root.activeNetwork.name : "WLAN  ·  OFFLINE"
                                color: root.activeNetwork ? Theme.ice : Theme.muted
                                font.family: Theme.font
                                font.pixelSize: 9
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            HoverHandler { id: wifiHover }
                            TapHandler { onTapped: ShellState.toggle("wifi") }
                        }

                        Rectangle {
                            implicitWidth: 68
                            implicitHeight: 25
                            radius: 8
                            color: volumeHover.hovered ? Theme.surfaceHigh : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: (root.muted ? "MUTE" : "VOL") + "  ·  " + Math.round(root.volume * 100)
                                color: root.muted ? Theme.danger : Theme.text
                                font.family: Theme.font
                                font.pixelSize: 9
                                font.bold: true
                            }

                            HoverHandler { id: volumeHover }
                            TapHandler {
                                onTapped: {
                                    if (root.sink?.audio)
                                        root.sink.audio.muted = !root.sink.audio.muted;
                                }
                            }
                            WheelHandler {
                                onWheel: event => root.setVolume(root.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05))
                            }
                        }

                        Rectangle {
                            visible: UPower.displayDevice.isLaptopBattery
                            implicitWidth: 68
                            implicitHeight: 25
                            radius: 8
                            color: batteryHover.hovered ? Theme.surfaceHigh : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "BAT  ·  " + Math.round(UPower.displayDevice.percentage * 100)
                                color: UPower.displayDevice.percentage < 0.15 ? Theme.danger : Theme.text
                                font.family: Theme.font
                                font.pixelSize: 9
                                font.bold: true
                            }

                            HoverHandler { id: batteryHover }
                        }

                        Rectangle {
                            implicitWidth: 52
                            implicitHeight: 25
                            radius: 8
                            color: helpHover.hovered ? Theme.blueSoft : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "GUIDE"
                                color: Theme.blue
                                font.family: Theme.font
                                font.pixelSize: 8
                                font.bold: true
                                font.letterSpacing: 0.7
                            }

                            HoverHandler { id: helpHover }
                            TapHandler { onTapped: ShellState.toggle("keybinds") }
                        }
                    }
                }
            }
        }
    }
}
