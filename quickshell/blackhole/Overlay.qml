pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: root

    property var pendingNetwork: null
    readonly property var wifiDevice: Networking.devices.values.find(device => device.type === DeviceType.Wifi) ?? null
    readonly property var targetScreen: {
        const focused = Hyprland.focusedMonitor;
        if (focused) {
            for (const screen of Quickshell.screens) {
                if (Hyprland.monitorFor(screen) === focused)
                    return screen;
            }
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    function chooseNetwork(network) {
        if (network.connected || network.stateChanging)
            return;
        if (network.known || network.security === WifiSecurityType.Open) {
            network.connect();
            return;
        }
        pendingNetwork = network;
        wifiPassword.text = "";
        wifiPassword.forceActiveFocus();
    }

    Connections {
        target: ShellState

        function onOverlayChanged() {
            if (root.wifiDevice)
                root.wifiDevice.scannerEnabled = ShellState.overlay === "wifi";
            if (ShellState.overlay === "")
                root.pendingNetwork = null;
        }
    }

    PanelWindow {
        id: overlay

        visible: ShellState.overlay !== ""
        screen: root.targetScreen
        color: "transparent"
        exclusiveZone: 0

        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        WlrLayershell.namespace: "blackhole-shell"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        HyprlandFocusGrab {
            active: overlay.visible
            windows: [overlay]
            onCleared: ShellState.close()
        }

        Rectangle {
            anchors.fill: parent
            color: "#99070402"

            MouseArea {
                anchors.fill: parent
                onClicked: ShellState.close()
            }
        }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: Math.min(920, overlay.width - 72)
            height: Math.min(ShellState.overlay === "power" ? 350 : 680, overlay.height - 72)
            radius: 26
            color: Theme.surfaceHigh
            border.width: 1
            border.color: Theme.outline

            MouseArea {
                anchors.fill: parent
                onClicked: event => event.accepted = true
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: ShellState.overlay === "launcher" ? "APPLICATION ORBIT" : ShellState.overlay === "wifi" ? "WIRELESS SPACE" : ShellState.overlay === "keybinds" ? "SHORTCUT ATLAS" : "EVENT HORIZON"
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 18
                            font.bold: true
                            font.letterSpacing: 1.2
                        }
                        Text {
                            text: ShellState.overlay === "wifi" ? "Native NetworkManager control — no nmcli" : "Type to filter  •  Esc to close"
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 10
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 11
                        color: closeHover.hovered ? "#5a2c17" : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: Theme.gold
                            font.pixelSize: 20
                        }
                        HoverHandler { id: closeHover }
                        TapHandler { onTapped: ShellState.close() }
                    }
                }

                TextField {
                    id: search
                    visible: ShellState.overlay === "launcher" || ShellState.overlay === "keybinds"
                    Layout.fillWidth: true
                    implicitHeight: 44
                    placeholderText: ShellState.overlay === "launcher" ? "Search applications…" : "Search app, key, or action…"
                    color: Theme.text
                    placeholderTextColor: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 12
                    selectByMouse: true
                    background: Rectangle {
                        radius: 13
                        color: "#aa120b07"
                        border.width: 1
                        border.color: search.activeFocus ? Theme.ember : Theme.outline
                    }
                    Keys.onEscapePressed: ShellState.close()
                    Component.onCompleted: forceActiveFocus()
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: ShellState.overlay === "launcher" ? launcherPage : ShellState.overlay === "wifi" ? wifiPage : ShellState.overlay === "keybinds" ? keybindPage : powerPage
                }
            }

            Keys.onEscapePressed: ShellState.close()
        }
    }

    Component {
        id: launcherPage

        ListView {
            id: appList
            clip: true
            spacing: 5
            model: ScriptModel {
                values: DesktopEntries.applications.values.filter(entry => {
                    const needle = search.text.toLowerCase().trim();
                    return needle.length === 0 || `${entry.name} ${entry.genericName} ${entry.comment}`.toLowerCase().includes(needle);
                }).slice(0, 80)
            }

            delegate: Rectangle {
                id: appRow
                required property var modelData
                width: appList.width
                height: 58
                radius: 14
                color: appHover.hovered ? "#4a2a19" : "#24120a"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 13

                    Image {
                        source: Quickshell.iconPath(appRow.modelData.icon, "application-x-executable")
                        sourceSize.width: 32
                        sourceSize.height: 32
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { text: appRow.modelData.name; color: Theme.text; font.family: Theme.font; font.pixelSize: 12; font.bold: true }
                        Text { text: appRow.modelData.genericName || appRow.modelData.comment; color: Theme.muted; font.family: Theme.font; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                    Text { text: "↵"; color: Theme.ember; font.family: Theme.font; font.pixelSize: 12 }
                }

                HoverHandler { id: appHover }
                TapHandler {
                    onTapped: {
                        appRow.modelData.execute();
                        ShellState.close();
                    }
                }
            }
        }
    }

    Component {
        id: wifiPage

        ColumnLayout {
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: Networking.wifiEnabled ? "󰖩  Wi-Fi enabled" : "󰖪  Wi-Fi disabled"
                    color: Networking.wifiEnabled ? Theme.amber : Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 12
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    implicitWidth: 92
                    implicitHeight: 34
                    radius: 12
                    color: Networking.wifiEnabled ? "#66401f12" : "#2b1a10"
                    Text { anchors.centerIn: parent; text: Networking.wifiEnabled ? "TURN OFF" : "TURN ON"; color: Theme.text; font.family: Theme.font; font.pixelSize: 9; font.bold: true }
                    TapHandler { onTapped: Networking.wifiEnabled = !Networking.wifiEnabled }
                }
            }

            Rectangle {
                visible: root.pendingNetwork !== null
                Layout.fillWidth: true
                implicitHeight: 74
                radius: 14
                color: "#2a160c"
                border.width: 1
                border.color: Theme.ember

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    Text { text: "󰌾  " + (root.pendingNetwork?.name ?? "Network"); color: Theme.text; font.family: Theme.font; font.pixelSize: 11 }
                    TextField {
                        id: wifiPassword
                        Layout.fillWidth: true
                        echoMode: TextInput.Password
                        placeholderText: "Wi-Fi password"
                        color: Theme.text
                        placeholderTextColor: Theme.muted
                        font.family: Theme.font
                        background: Rectangle { radius: 10; color: "#120b07"; border.width: 1; border.color: Theme.outline }
                        onAccepted: {
                            if (root.pendingNetwork && text.length > 0) {
                                root.pendingNetwork.connectWithPsk(text);
                                root.pendingNetwork = null;
                            }
                        }
                    }
                    Rectangle {
                        implicitWidth: 86
                        implicitHeight: 34
                        radius: 10
                        color: Theme.ember
                        Text { anchors.centerIn: parent; text: "CONNECT"; color: Theme.voidBlack; font.family: Theme.font; font.pixelSize: 9; font.bold: true }
                        TapHandler {
                            onTapped: {
                                if (root.pendingNetwork && wifiPassword.text.length > 0) {
                                    root.pendingNetwork.connectWithPsk(wifiPassword.text);
                                    root.pendingNetwork = null;
                                }
                            }
                        }
                    }
                }
            }

            ListView {
                id: networkList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 5
                model: root.wifiDevice?.networks ?? null

                delegate: Rectangle {
                    id: networkRow
                    required property var modelData
                    width: networkList.width
                    height: 54
                    radius: 14
                    color: modelData.connected ? "#66401f12" : networkHover.hovered ? "#4a2a19" : "#24120a"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        Text {
                            text: modelData.signalStrength > 0.7 ? "󰤨" : modelData.signalStrength > 0.4 ? "󰤥" : "󰤟"
                            color: modelData.connected ? Theme.amber : Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 16
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text { text: networkRow.modelData.name || "Hidden network"; color: Theme.text; font.family: Theme.font; font.pixelSize: 11; font.bold: networkRow.modelData.connected }
                            Text { text: networkRow.modelData.connected ? "connected" : networkRow.modelData.known ? "saved" : WifiSecurityType.toString(networkRow.modelData.security); color: Theme.muted; font.family: Theme.font; font.pixelSize: 9 }
                        }
                        Text { text: networkRow.modelData.stateChanging ? "orbiting…" : networkRow.modelData.connected ? "●" : "CONNECT"; color: networkRow.modelData.connected ? Theme.amber : Theme.ember; font.family: Theme.font; font.pixelSize: 9; font.bold: true }
                    }

                    HoverHandler { id: networkHover }
                    TapHandler { onTapped: root.chooseNetwork(networkRow.modelData) }
                }

                Text {
                    visible: root.wifiDevice === null
                    anchors.centerIn: parent
                    text: "No Wi-Fi adapter found"
                    color: Theme.muted
                    font.family: Theme.font
                }
            }
        }
    }

    Component {
        id: keybindPage

        ListView {
            id: keyList
            clip: true
            spacing: 5
            model: KeybindData.entries.filter(entry => {
                const needle = search.text.toLowerCase().trim();
                return needle.length === 0 || `${entry.app} ${entry.key} ${entry.action}`.toLowerCase().includes(needle);
            })

            delegate: Rectangle {
                id: keyRow
                required property var modelData
                width: keyList.width
                height: 54
                radius: 14
                color: keyHover.hovered ? "#4a2a19" : "#24120a"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12
                    Text { text: keyRow.modelData.app; color: Theme.amber; font.family: Theme.font; font.pixelSize: 9; font.bold: true; Layout.preferredWidth: 82 }
                    Text { text: keyRow.modelData.action; color: Theme.text; font.family: Theme.font; font.pixelSize: 10; Layout.fillWidth: true; elide: Text.ElideRight }
                    Rectangle {
                        implicitWidth: keyText.implicitWidth + 18
                        implicitHeight: 30
                        radius: 9
                        color: "#352015"
                        Text { id: keyText; anchors.centerIn: parent; text: keyRow.modelData.key; color: Theme.ember; font.family: Theme.font; font.pixelSize: 9; font.bold: true }
                    }
                }
                HoverHandler { id: keyHover }
            }
        }
    }

    Component {
        id: powerPage

        RowLayout {
            spacing: 14

            Repeater {
                model: [
                    { icon: "󰌾", label: "LOCK", command: ["hyprlock", "--immediate"], colour: Theme.amber },
                    { icon: "󰍃", label: "LOG OUT", command: ["hyprctl", "dispatch", "exit"], colour: Theme.ember },
                    { icon: "󰒲", label: "SUSPEND", command: ["systemctl", "suspend"], colour: Theme.warning },
                    { icon: "󰜉", label: "REBOOT", command: ["systemctl", "reboot"], colour: Theme.gold },
                    { icon: "󰐥", label: "POWER OFF", command: ["systemctl", "poweroff"], colour: Theme.danger }
                ]

                Rectangle {
                    id: powerAction
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 18
                    color: powerHover.hovered ? "#4b2917" : "#1d1009"
                    border.width: 1
                    border.color: powerHover.hovered ? modelData.colour : Theme.outline

                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: powerAction.modelData.icon; color: powerAction.modelData.colour; font.family: Theme.font; font.pixelSize: 34 }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: powerAction.modelData.label; color: Theme.text; font.family: Theme.font; font.pixelSize: 9; font.bold: true }
                    }

                    HoverHandler { id: powerHover }
                    TapHandler {
                        onTapped: {
                            Quickshell.execDetached(powerAction.modelData.command);
                            ShellState.close();
                        }
                    }
                }
            }
        }
    }
}
