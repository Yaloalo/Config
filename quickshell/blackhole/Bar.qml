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

    PwObjectTracker {
        objects: [root.sink]
    }

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
            implicitHeight: 48
            exclusiveZone: 48

            anchors {
                top: true
                left: true
                right: true
            }

            WlrLayershell.namespace: "blackhole-shell"

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 6
                anchors.bottomMargin: 4
                radius: 15
                color: Theme.surface
                border.width: 1
                border.color: Theme.outline

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 28
                        radius: 10
                        color: logoHover.hovered ? "#4b2917" : "#2a160c"

                        Text {
                            anchors.centerIn: parent
                            text: "󰚩"
                            color: Theme.ember
                            font.family: Theme.font
                            font.pixelSize: 17
                        }

                        HoverHandler { id: logoHover }
                        TapHandler { onTapped: ShellState.toggle("launcher") }
                    }

                    Rectangle {
                        implicitWidth: monitorText.implicitWidth + 18
                        implicitHeight: 28
                        radius: 10
                        color: window.hyprMonitor?.focused ? "#3b210f" : "#24140b"
                        border.width: 1
                        border.color: window.hyprMonitor?.focused ? Theme.amber : Theme.outline

                        Text {
                            id: monitorText
                            anchors.centerIn: parent
                            text: (window.hyprMonitor?.name ?? window.modelData.name)
                                + "  ·  " + (window.hyprMonitor?.activeWorkspace?.name ?? "—")
                            color: window.hyprMonitor?.focused ? Theme.gold : Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 10
                            font.bold: window.hyprMonitor?.focused ?? false
                        }
                    }

                    RowLayout {
                        spacing: 3

                        Repeater {
                            model: window.localWorkspaces

                            Rectangle {
                                id: workspace
                                required property var modelData
                                readonly property bool active: modelData.active

                                implicitWidth: active ? 28 : 20
                                implicitHeight: 25
                                radius: 9
                                color: active ? Theme.ember : workspaceHover.hovered ? "#352015" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: workspace.modelData.id
                                    color: workspace.active ? Theme.voidBlack : Theme.muted
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    font.bold: workspace.active
                                }

                                Behavior on implicitWidth { NumberAnimation { duration: 140 } }
                                Behavior on color { ColorAnimation { duration: 140 } }
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

                                implicitWidth: 24
                                implicitHeight: 25
                                radius: 9
                                color: modelData.active ? Theme.amber : namedHover.hovered ? "#352015" : "transparent"
                                border.width: modelData.label === "E" ? 1 : 0
                                border.color: modelData.active ? Theme.gold : Theme.outline

                                Text {
                                    anchors.centerIn: parent
                                    text: namedWorkspace.modelData.label
                                    color: namedWorkspace.modelData.active ? Theme.voidBlack : Theme.muted
                                    font.family: Theme.font
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Behavior on color { ColorAnimation { duration: 140 } }
                                HoverHandler { id: namedHover }
                                TapHandler {
                                    onTapped: Hyprland.dispatch(namedWorkspace.modelData.label === "E"
                                        ? "hl.dsp.workspace.toggle_special(\"term\")"
                                        : "hl.dsp.focus({ workspace = " + namedWorkspace.modelData.target + " })")
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "BLACK HOLE  •  " + Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 5

                        Repeater {
                            model: SystemTray.items

                            Image {
                                id: trayIcon
                                required property var modelData
                                source: modelData.icon
                                sourceSize.width: 17
                                sourceSize.height: 17
                                Layout.preferredWidth: 23
                                Layout.preferredHeight: 23
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
                            implicitWidth: wifiText.implicitWidth + 18
                            implicitHeight: 28
                            radius: 10
                            color: wifiHover.hovered ? "#352015" : "transparent"

                            Text {
                                id: wifiText
                                anchors.centerIn: parent
                                text: root.activeNetwork ? "󰖩  " + root.activeNetwork.name : "󰖪  offline"
                                color: root.activeNetwork ? Theme.amber : Theme.muted
                                font.family: Theme.font
                                font.pixelSize: 11
                            }

                            HoverHandler { id: wifiHover }
                            TapHandler { onTapped: ShellState.toggle("wifi") }
                        }

                        Rectangle {
                            implicitWidth: volumeText.implicitWidth + 16
                            implicitHeight: 28
                            radius: 10
                            color: volumeHover.hovered ? "#352015" : "transparent"

                            Text {
                                id: volumeText
                                anchors.centerIn: parent
                                text: (root.muted ? "󰖁" : root.volume > 0.55 ? "󰕾" : "󰖀") + "  " + Math.round(root.volume * 100) + "%"
                                color: root.muted ? Theme.danger : Theme.ember
                                font.family: Theme.font
                                font.pixelSize: 11
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
                            implicitWidth: batteryText.implicitWidth + 16
                            implicitHeight: 28
                            radius: 10
                            color: batteryHover.hovered ? "#352015" : "transparent"

                            Text {
                                id: batteryText
                                anchors.centerIn: parent
                                text: "󰁹  " + Math.round(UPower.displayDevice.percentage * 100) + "%"
                                color: UPower.displayDevice.percentage < 0.15 ? Theme.danger : Theme.text
                                font.family: Theme.font
                                font.pixelSize: 11
                            }

                            HoverHandler { id: batteryHover }
                        }

                        Rectangle {
                            implicitWidth: 29
                            implicitHeight: 28
                            radius: 10
                            color: helpHover.hovered ? "#4b2917" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "󰌌"
                                color: Theme.gold
                                font.family: Theme.font
                                font.pixelSize: 14
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
