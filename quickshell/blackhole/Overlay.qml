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
    property string selectedKeyApp: "Hyprland"
    readonly property var keyApps: ["Hyprland", "WezTerm", "Neovim", "Yazi", "Zsh"]
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

    function entryCount(app) {
        return KeybindData.entries.filter(entry => entry.app === app).length;
    }

    Connections {
        target: ShellState

        function onOverlayChanged() {
            if (root.wifiDevice)
                root.wifiDevice.scannerEnabled = ShellState.overlay === "wifi";
            if (ShellState.overlay === "keybinds")
                root.selectedKeyApp = "Hyprland";
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

        anchors { top: true; right: true; bottom: true; left: true }
        WlrLayershell.namespace: "infinity-shell"
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
            color: "#c0000105"
            MouseArea { anchors.fill: parent; onClicked: ShellState.close() }
        }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: Math.min(ShellState.overlay === "wifi" ? 760 : ShellState.overlay === "power" ? 800 : 940, overlay.width - 72)
            height: Math.min(ShellState.overlay === "power" ? 310 : 680, overlay.height - 72)
            radius: 20
            color: Theme.surfaceHigh
            border.width: 1
            border.color: Theme.outline

            MouseArea { anchors.fill: parent; onClicked: event => event.accepted = true }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: ShellState.overlay === "launcher" ? "APPLICATIONS"
                                : ShellState.overlay === "wifi" ? "WIRELESS"
                                : ShellState.overlay === "keybinds" ? "CONTROL INDEX"
                                : "SESSION"
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 16
                            font.bold: true
                            font.letterSpacing: 1.5
                        }
                        Text {
                            text: ShellState.overlay === "wifi" ? "NetworkManager  /  direct control"
                                : ShellState.overlay === "keybinds" ? "Choose a service, or search across everything"
                                : "Type to filter  /  Escape to close"
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 9
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 9
                        color: closeHover.hovered ? Theme.blueSoft : "transparent"
                        Text { anchors.centerIn: parent; text: "×"; color: Theme.ice; font.pixelSize: 18 }
                        HoverHandler { id: closeHover }
                        TapHandler { onTapped: ShellState.close() }
                    }
                }

                TextField {
                    id: search
                    visible: ShellState.overlay === "launcher" || ShellState.overlay === "keybinds"
                    Layout.fillWidth: true
                    implicitHeight: 42
                    leftPadding: 14
                    rightPadding: 14
                    placeholderText: ShellState.overlay === "launcher" ? "Search applications…" : "Search every app, key, or action…"
                    color: Theme.text
                    placeholderTextColor: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 11
                    selectByMouse: true
                    background: Rectangle {
                        radius: 11
                        color: Theme.panel
                        border.width: 1
                        border.color: search.activeFocus ? Theme.blue : Theme.outline
                    }
                    Keys.onEscapePressed: ShellState.close()
                    Component.onCompleted: forceActiveFocus()
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: ShellState.overlay === "launcher" ? launcherPage
                        : ShellState.overlay === "wifi" ? wifiPage
                        : ShellState.overlay === "keybinds" ? keybindPage
                        : powerPage
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
            spacing: 6
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
                height: 56
                radius: 12
                color: appHover.hovered ? Theme.surfaceHigh : Theme.panel
                border.width: 1
                border.color: appHover.hovered ? Theme.blue : Theme.outline

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 13
                    anchors.rightMargin: 13
                    spacing: 12

                    Image {
                        source: Quickshell.iconPath(appRow.modelData.icon, "application-x-executable")
                        sourceSize.width: 29
                        sourceSize.height: 29
                        Layout.preferredWidth: 31
                        Layout.preferredHeight: 31
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { text: appRow.modelData.name; color: Theme.text; font.family: Theme.font; font.pixelSize: 11; font.bold: true }
                        Text { text: appRow.modelData.genericName || appRow.modelData.comment; color: Theme.muted; font.family: Theme.font; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                    Text { text: "ENTER"; color: Theme.blue; font.family: Theme.font; font.pixelSize: 8; font.bold: true }
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

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 54
                radius: 13
                color: Theme.panel
                border.width: 1
                border.color: Theme.outline

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 10

                    ColumnLayout {
                        spacing: 0
                        Text { text: "WIRELESS RADIO"; color: Theme.text; font.family: Theme.font; font.pixelSize: 10; font.bold: true; font.letterSpacing: 0.8 }
                        Text { text: Networking.wifiEnabled ? "enabled  /  scanning nearby networks" : "disabled"; color: Networking.wifiEnabled ? Theme.blue : Theme.muted; font.family: Theme.font; font.pixelSize: 9 }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        implicitWidth: 88
                        implicitHeight: 32
                        radius: 9
                        color: Networking.wifiEnabled ? Theme.blueSoft : Theme.surfaceHigh
                        border.width: 1
                        border.color: Networking.wifiEnabled ? Theme.blue : Theme.outline
                        Text { anchors.centerIn: parent; text: Networking.wifiEnabled ? "DISABLE" : "ENABLE"; color: Theme.text; font.family: Theme.font; font.pixelSize: 8; font.bold: true }
                        TapHandler { onTapped: Networking.wifiEnabled = !Networking.wifiEnabled }
                    }
                }
            }

            Rectangle {
                visible: root.pendingNetwork !== null
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 68 : 0
                radius: 13
                color: Theme.panel
                border.width: 1
                border.color: Theme.blue

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 11
                    spacing: 10
                    Text { text: root.pendingNetwork?.name ?? "Network"; color: Theme.text; font.family: Theme.font; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 150; elide: Text.ElideRight }
                    TextField {
                        id: wifiPassword
                        Layout.fillWidth: true
                        implicitHeight: 36
                        echoMode: TextInput.Password
                        placeholderText: "Password"
                        color: Theme.text
                        placeholderTextColor: Theme.muted
                        font.family: Theme.font
                        background: Rectangle { radius: 9; color: Theme.voidBlack; border.width: 1; border.color: Theme.outline }
                        onAccepted: {
                            if (root.pendingNetwork && text.length > 0) {
                                root.pendingNetwork.connectWithPsk(text);
                                root.pendingNetwork = null;
                            }
                        }
                    }
                    Rectangle {
                        implicitWidth: 84
                        implicitHeight: 36
                        radius: 9
                        color: Theme.ice
                        Text { anchors.centerIn: parent; text: "CONNECT"; color: Theme.voidBlack; font.family: Theme.font; font.pixelSize: 8; font.bold: true }
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
                spacing: 6
                model: root.wifiDevice?.networks ?? null

                delegate: Rectangle {
                    id: networkRow
                    required property var modelData
                    width: networkList.width
                    height: 56
                    radius: 12
                    color: modelData.connected ? Theme.blueSoft : networkHover.hovered ? Theme.surfaceHigh : Theme.panel
                    border.width: 1
                    border.color: modelData.connected ? Theme.blue : Theme.outline

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 10
                        spacing: 12

                        Text {
                            text: Math.round(networkRow.modelData.signalStrength * 100) + "%"
                            color: networkRow.modelData.connected ? Theme.ice : Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 9
                            font.bold: true
                            Layout.preferredWidth: 40
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text { text: networkRow.modelData.name || "Hidden network"; color: Theme.text; font.family: Theme.font; font.pixelSize: 11; font.bold: networkRow.modelData.connected }
                            Text { text: networkRow.modelData.connected ? "connected" : networkRow.modelData.known ? "saved network" : WifiSecurityType.toString(networkRow.modelData.security); color: Theme.muted; font.family: Theme.font; font.pixelSize: 8 }
                        }
                        Rectangle {
                            implicitWidth: 86
                            implicitHeight: 30
                            radius: 8
                            color: networkRow.modelData.connected ? Theme.ice : "transparent"
                            border.width: networkRow.modelData.connected ? 0 : 1
                            border.color: Theme.outline
                            Text {
                                anchors.centerIn: parent
                                text: networkRow.modelData.stateChanging ? "WAIT" : networkRow.modelData.connected ? "ONLINE" : "CONNECT"
                                color: networkRow.modelData.connected ? Theme.voidBlack : Theme.blue
                                font.family: Theme.font
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }
                    }

                    HoverHandler { id: networkHover }
                    TapHandler { onTapped: root.chooseNetwork(networkRow.modelData) }
                }

                Text {
                    visible: root.wifiDevice === null
                    anchors.centerIn: parent
                    text: "No wireless adapter found"
                    color: Theme.muted
                    font.family: Theme.font
                }
            }
        }
    }

    Component {
        id: keybindPage

        RowLayout {
            spacing: 12

            ListView {
                id: appSelector
                visible: search.text.trim().length === 0
                Layout.preferredWidth: visible ? 170 : 0
                Layout.fillHeight: true
                spacing: 6
                clip: true
                model: root.keyApps

                delegate: Rectangle {
                    id: appChoice
                    required property string modelData
                    width: appSelector.width
                    height: 52
                    radius: 11
                    color: root.selectedKeyApp === modelData ? Theme.blueSoft : appChoiceHover.hovered ? Theme.surfaceHigh : Theme.panel
                    border.width: 1
                    border.color: root.selectedKeyApp === modelData ? Theme.blue : Theme.outline

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 13
                        spacing: 1
                        Text { text: appChoice.modelData; color: root.selectedKeyApp === appChoice.modelData ? Theme.ice : Theme.text; font.family: Theme.font; font.pixelSize: 10; font.bold: true }
                        Text { text: root.entryCount(appChoice.modelData) + " shortcuts"; color: Theme.muted; font.family: Theme.font; font.pixelSize: 8 }
                    }
                    HoverHandler { id: appChoiceHover }
                    TapHandler { onTapped: root.selectedKeyApp = appChoice.modelData }
                }
            }

            ListView {
                id: keyList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: KeybindData.entries.filter(entry => {
                    const needle = search.text.toLowerCase().trim();
                    return needle.length > 0
                        ? `${entry.app} ${entry.key} ${entry.action}`.toLowerCase().includes(needle)
                        : entry.app === root.selectedKeyApp;
                })

                delegate: Rectangle {
                    id: keyRow
                    required property var modelData
                    width: keyList.width
                    height: 52
                    radius: 11
                    color: keyHover.hovered ? Theme.surfaceHigh : Theme.panel
                    border.width: 1
                    border.color: keyHover.hovered ? Theme.blue : Theme.outline

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 13
                        anchors.rightMargin: 10
                        spacing: 11
                        Text {
                            visible: search.text.trim().length > 0
                            text: keyRow.modelData.app
                            color: Theme.blue
                            font.family: Theme.font
                            font.pixelSize: 8
                            font.bold: true
                            Layout.preferredWidth: 70
                        }
                        Text { text: keyRow.modelData.action; color: Theme.text; font.family: Theme.font; font.pixelSize: 9; Layout.fillWidth: true; elide: Text.ElideRight }
                        Rectangle {
                            implicitWidth: keyText.implicitWidth + 18
                            implicitHeight: 28
                            radius: 8
                            color: Theme.surfaceHigh
                            border.width: 1
                            border.color: Theme.outline
                            Text { id: keyText; anchors.centerIn: parent; text: keyRow.modelData.key; color: Theme.ice; font.family: Theme.font; font.pixelSize: 8; font.bold: true }
                        }
                    }
                    HoverHandler { id: keyHover }
                }
            }
        }
    }

    Component {
        id: powerPage

        RowLayout {
            spacing: 10

            Repeater {
                model: [
                    { label: "LOCK", detail: "secure session", command: ["hyprlock", "--immediate"], colour: Theme.ice },
                    { label: "LOG OUT", detail: "end Hyprland", command: ["hyprctl", "dispatch", "hl.dsp.exit()"], colour: Theme.blue },
                    { label: "SUSPEND", detail: "sleep system", command: ["systemctl", "suspend"], colour: Theme.text },
                    { label: "REBOOT", detail: "restart system", command: ["systemctl", "reboot"], colour: Theme.warning },
                    { label: "POWER OFF", detail: "shut down", command: ["systemctl", "poweroff"], colour: Theme.danger }
                ]

                Rectangle {
                    id: powerAction
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 14
                    color: powerHover.hovered ? Theme.surfaceHigh : Theme.panel
                    border.width: 1
                    border.color: powerHover.hovered ? modelData.colour : Theme.outline

                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: powerAction.modelData.label; color: powerAction.modelData.colour; font.family: Theme.font; font.pixelSize: 10; font.bold: true; font.letterSpacing: 0.7 }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: powerAction.modelData.detail; color: Theme.muted; font.family: Theme.font; font.pixelSize: 8 }
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
