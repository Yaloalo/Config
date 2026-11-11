pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Wayland
import QtQuick
import qs.common
import QtQuick.Layouts

Scope {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var activeNetwork: wifiDevice?.networks.values.find(n => n.connected) ?? null
    function setVolume(value) {
        if (sink?.ready && sink.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1, value));
        }
    }
    SystemClock { id: clock; precision: SystemClock.Minutes }
    PwObjectTracker { objects: [root.sink] }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: window
            required property var modelData
            readonly property var monitor: Hyprland.monitorFor(modelData)
            property bool terminalVisible: false
            screen: modelData
            visible: ShellState.barVisible
            color: "transparent"
            implicitHeight: 36
            exclusiveZone: 36
            anchors { top: true; left: true; right: true }
            WlrLayershell.namespace: "infinity-shell"
            Process {
                id: query
                command: ["hyprctl", "monitors", "-j"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            const m = JSON.parse(text).find(m => m.name === window.modelData.name);
                            window.terminalVisible = m?.specialWorkspace?.name === "special:term";
                        } catch (error) {}
                    }
                }
            }
            Timer { id: refresh; interval: 30; onTriggered: query.running = true }
            Connections {
                target: Hyprland
                function onRawEvent(event) {
                    if (["activespecial", "activespecialv2", "focusedmon", "monitoradded", "monitorremoved"].includes(event.name))
                        refresh.restart();
                }
            }
            Component.onCompleted: query.running = true
            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: Theme.r(9)
                color: Theme.surface
                border.color: Theme.outline
                SpaceField { preferences: Preferences; moving: ShellState.motionEnabled; anchors.fill: parent; starCount: 90; strength: 0.4 }
                Row {
                    anchors.left: parent.left; anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12
                    Text {
                        text: window.modelData.name + " / " + (window.terminalVisible ? "E" : (window.monitor?.activeWorkspace?.name ?? ""))
                        color: Theme.fg; font.family: Theme.font; font.pixelSize: Theme.fs(10)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Repeater {
                        model: ["E", "W", "Q"]
                        Rectangle {
                            id: chip
                            required property string modelData
                            readonly property bool active: modelData === "E" ? window.terminalVisible
                                : !window.terminalVisible && window.monitor?.activeWorkspace?.id === (modelData === "W" ? 10 : 11)
                            width: 22; height: 22; radius: Theme.r(6)
                            color: active ? Theme.fg : "transparent"
                            Text { anchors.centerIn: parent; text: chip.modelData; color: chip.active ? Theme.onFg : Theme.muted; font.pixelSize: Theme.fs(10); font.family: Theme.font }
                            TapHandler {
                                onTapped: Hyprland.dispatch(chip.modelData === "E" ? 'hl.dsp.workspace.toggle_special("term")'
                                    : "hl.dsp.focus({ workspace = " + (chip.modelData === "W" ? 10 : 11) + " })")
                            }
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")
                    color: Theme.fg; font.family: Theme.font; font.pixelSize: Theme.fs(10)
                }
                Row {
                    anchors.right: parent.right; anchors.rightMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 15
                    StatusIcon {
                        kind: "wifi"; width: 20; height: 20
                        color: root.activeNetwork ? Theme.fg : Theme.muted
                        TapHandler { onTapped: ShellState.toggle("wifi") }
                    }
                    Row {
                        spacing: 5
                        StatusIcon { kind: root.muted ? "muted" : "volume"; width: 20; height: 20 }
                        Text { text: Math.round(root.volume * 100); color: Theme.fg; font.family: Theme.font; font.pixelSize: Theme.fs(10); anchors.verticalCenter: parent.verticalCenter }
                        TapHandler { onTapped: { if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted; } }
                        WheelHandler { onWheel: event => root.setVolume(root.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)) }
                    }
                    Row {
                        visible: UPower.displayDevice.isLaptopBattery
                        spacing: 5
                        StatusIcon { kind: "battery"; width: 20; height: 20; level: UPower.displayDevice.percentage; charging: !UPower.onBattery; color: level < 0.15 && !charging ? Theme.danger : Theme.fg }
                        Text { text: Math.round(UPower.displayDevice.percentage * 100) + "%"; color: Theme.fg; font.family: Theme.font; font.pixelSize: Theme.fs(10); anchors.verticalCenter: parent.verticalCenter }
                    }
                    StatusIcon {
                        kind: "settings"; width: 20; height: 20
                        color: Preferences.ecoMode ? Theme.comet : Theme.fg
                        TapHandler { onTapped: ShellState.toggle("settings") }
                    }
                }
            }
        }
    }
}
