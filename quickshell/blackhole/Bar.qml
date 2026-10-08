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
                        color: logoHover.hovered ? "#44355f" : "#2b203e"

                        Text {
                            anchors.centerIn: parent
                            text: "󰚩"
                            color: Theme.violet
                            font.family: Theme.font
                            font.pixelSize: 17
                        }

                        HoverHandler { id: logoHover }
                        TapHandler { onTapped: ShellState.toggle("launcher") }
                    }

                    RowLayout {
                        spacing: 3

                        Repeater {
                            model: 10

                            Rectangle {
                                id: workspace
                                required property int index
                                readonly property int number: index + 1
                                readonly property bool active: Hyprland.focusedWorkspace?.id === number

                                implicitWidth: active ? 28 : 20
                                implicitHeight: 25
                                radius: 9
                                color: active ? Theme.violet : workspaceHover.hovered ? "#302945" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: workspace.number
                                    color: workspace.active ? Theme.voidBlack : Theme.muted
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    font.bold: workspace.active
                                }

                                Behavior on implicitWidth { NumberAnimation { duration: 140 } }
                                Behavior on color { ColorAnimation { duration: 140 } }
                                HoverHandler { id: workspaceHover }
                                TapHandler { onTapped: Hyprland.dispatch("workspace " + workspace.number) }
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
                            color: wifiHover.hovered ? "#302945" : "transparent"

                            Text {
                                id: wifiText
                                anchors.centerIn: parent
                                text: root.activeNetwork ? "󰖩  " + root.activeNetwork.name : "󰖪  offline"
                                color: root.activeNetwork ? Theme.cyan : Theme.muted
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
                            color: volumeHover.hovered ? "#302945" : "transparent"

                            Text {
                                id: volumeText
                                anchors.centerIn: parent
                                text: (root.muted ? "󰖁" : root.volume > 0.55 ? "󰕾" : "󰖀") + "  " + Math.round(root.volume * 100) + "%"
                                color: root.muted ? Theme.danger : Theme.violet
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
                            color: batteryHover.hovered ? "#302945" : "transparent"

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
                            color: helpHover.hovered ? "#44355f" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "󰌌"
                                color: Theme.pink
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
