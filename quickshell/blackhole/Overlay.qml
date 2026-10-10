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
    property int launcherIndex: 0
    property int keyAppIndex: 0
    property int keyEntryIndex: 0
    property int keyPane: 0
    property bool keySearchMode: false
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
    }

    function entryCount(app) {
        return KeybindData.entries.filter(entry => entry.app === app).length;
    }

    function filteredApps() {
        const needle = search.text.toLowerCase().trim();
        return DesktopEntries.applications.values.filter(entry =>
            needle.length === 0
                || `${entry.name} ${entry.genericName} ${entry.comment}`.toLowerCase().includes(needle)
        ).slice(0, 80);
    }

    function filteredKeys() {
        const needle = search.text.toLowerCase().trim();
        return KeybindData.entries.filter(entry => needle.length > 0
            ? `${entry.app} ${entry.key} ${entry.action}`.toLowerCase().includes(needle)
            : entry.app === selectedKeyApp);
    }

    function wrapped(index, count, delta) {
        if (count <= 0)
            return 0;
        return (index + delta + count) % count;
    }

    function moveLauncher(delta) {
        launcherIndex = wrapped(launcherIndex, filteredApps().length, delta);
    }

    function launchSelected() {
        const apps = filteredApps();
        if (apps.length === 0)
            return;
        launcherIndex = Math.max(0, Math.min(launcherIndex, apps.length - 1));
        apps[launcherIndex].execute();
        ShellState.close();
    }

    function selectKeyApp(index) {
        keyAppIndex = wrapped(index, keyApps.length, 0);
        selectedKeyApp = keyApps[keyAppIndex];
        keyEntryIndex = 0;
    }

    function moveKeySelection(delta) {
        if (keyPane === 0 && search.text.trim().length === 0)
            selectKeyApp(wrapped(keyAppIndex, keyApps.length, delta));
        else
            keyEntryIndex = wrapped(keyEntryIndex, filteredKeys().length, delta);
    }

    function handleSearchKey(event) {
        const launcher = ShellState.overlay === "launcher";
        const keybinds = ShellState.overlay === "keybinds";
        const emptyQuery = search.text.trim().length === 0;
        const navigating = keybinds && !keySearchMode;

        if (keybinds && event.key === Qt.Key_Slash && !keySearchMode) {
            keySearchMode = true;
            event.accepted = true;
            return;
        }
        if (keybinds && event.key === Qt.Key_Escape && keySearchMode) {
            search.text = "";
            keySearchMode = false;
            keyPane = 0;
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Escape) {
            ShellState.close();
            event.accepted = true;
            return;
        }

        if (launcher && (event.key === Qt.Key_Down || event.key === Qt.Key_Up)) {
            moveLauncher(event.key === Qt.Key_Down ? 1 : -1);
            event.accepted = true;
        } else if (launcher && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            launchSelected();
            event.accepted = true;
        } else if (keybinds && (event.key === Qt.Key_Down || event.key === Qt.Key_Up
                || (navigating && (event.key === Qt.Key_J || event.key === Qt.Key_K)))) {
            moveKeySelection(event.key === Qt.Key_Down || event.key === Qt.Key_J ? 1 : -1);
            event.accepted = true;
        } else if (navigating && emptyQuery
                && (event.key === Qt.Key_Left || event.key === Qt.Key_H)) {
            keyPane = 0;
            event.accepted = true;
        } else if (navigating && emptyQuery
                && (event.key === Qt.Key_Right || event.key === Qt.Key_L
                    || event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            keyPane = 1;
            event.accepted = true;
        }
    }

    Connections {
        target: ShellState

        function onOverlayChanged() {
            if (root.wifiDevice)
                root.wifiDevice.scannerEnabled = ShellState.overlay === "wifi";
            if (ShellState.overlay !== "") {
                search.text = "";
                root.launcherIndex = 0;
                root.keyPane = 0;
                root.keySearchMode = false;
                root.keyEntryIndex = 0;
                root.selectKeyApp(0);
                Qt.callLater(() => search.visible ? search.forceActiveFocus() : card.forceActiveFocus());
            }
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

        Rectangle {
            anchors.fill: parent
            color: "#78000105"
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
            clip: true

            SpaceField { preferences: Preferences; moving: ShellState.motionEnabled;
                anchors.fill: parent
                starCount: 110
                seed: 17
                strength: 0.62
            }

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
                                : ShellState.overlay === "settings" ? "SETTINGS"
                                : "SESSION"
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 16
                            font.bold: true
                            font.letterSpacing: 1.5
                        }
                        Text {
                            text: ShellState.overlay === "wifi" ? "NetworkManager  /  direct control"
                                : ShellState.overlay === "settings" ? "Appearance, energy, devices and session"
                                : ShellState.overlay === "keybinds" ? "↑↓ or J/K navigate  /  H/L change pane  /  / search  /  Esc back"
                                : "Type to filter  /  ↑↓ select  /  Enter launch  /  Escape close"
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
                    placeholderText: ShellState.overlay === "launcher" ? "Search applications…"
                        : root.keySearchMode ? "Search every app, key, or action…" : "Press / to search; H/J/K/L navigate"
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
                        clip: true
                        SpaceField { preferences: Preferences; moving: ShellState.motionEnabled; anchors.fill: parent; starCount: 14; seed: 31; strength: 0.34 }
                    }
                    Keys.onPressed: event => root.handleSearchKey(event)
                    onTextChanged: {
                        root.launcherIndex = 0;
                        root.keyEntryIndex = 0;
                        if (text.trim().length > 0)
                            root.keyPane = 1;
                    }
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: ShellState.overlay === "launcher" ? launcherPage
                        : ShellState.overlay === "wifi" ? wifiPage
                        : ShellState.overlay === "keybinds" ? keybindPage
                        : ShellState.overlay === "settings" ? settingsPage
                        : powerPage
                }
            }

            Keys.onEscapePressed: ShellState.close()
        }
    }

    Component {
        id: settingsPage
        SettingsPage {}
    }

    Component {
        id: launcherPage

        ListView {
            id: appList
            clip: true
            spacing: 6
            model: ScriptModel {
                values: root.filteredApps()
            }
            currentIndex: root.launcherIndex
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: Rectangle {
                id: appRow
                required property var modelData
                required property int index
                readonly property bool selected: appList.currentIndex === index
                width: appList.width
                height: 56
                radius: 12
                color: selected ? Theme.blueSoft : appHover.hovered ? Theme.surfaceHigh : Theme.panel
                border.width: 1
                border.color: selected || appHover.hovered ? Theme.blue : Theme.outline

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 13
                    anchors.rightMargin: 13
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 31
                        Layout.preferredHeight: 31
                        radius: 9
                        color: Theme.blueSoft
                        border.width: 1
                        border.color: Theme.outline
                        Text {
                            anchors.centerIn: parent
                            text: appRow.modelData.name.slice(0, 2).toUpperCase()
                            color: Theme.ice
                            font.family: Theme.font
                            font.pixelSize: 10
                        }
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
                        root.launcherIndex = appRow.index;
                        root.launchSelected();
                    }
                }
            }

            Text {
                visible: appList.count === 0
                anchors.centerIn: parent
                text: "NO APPLICATIONS IN THIS ORBIT"
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 9
                font.letterSpacing: 1.1
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
                        onVisibleChanged: if (visible) { text = ""; forceActiveFocus(); }
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
                currentIndex: root.keyAppIndex
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    id: appChoice
                    required property string modelData
                    required property int index
                    readonly property bool selected: root.selectedKeyApp === modelData
                    width: appSelector.width
                    height: 52
                    radius: 11
                    color: selected ? Theme.blueSoft : appChoiceHover.hovered ? Theme.surfaceHigh : Theme.panel
                    border.width: 1
                    border.color: selected && root.keyPane === 0 ? Theme.comet
                        : selected ? Theme.blue : Theme.outline

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 13
                        spacing: 1
                        Text { text: appChoice.modelData; color: appChoice.selected ? Theme.ice : Theme.text; font.family: Theme.font; font.pixelSize: 10; font.bold: true }
                        Text { text: root.entryCount(appChoice.modelData) + " shortcuts"; color: Theme.muted; font.family: Theme.font; font.pixelSize: 8 }
                    }
                    HoverHandler { id: appChoiceHover }
                    TapHandler { onTapped: { root.selectKeyApp(appChoice.index); root.keyPane = 0; } }
                }
            }

            ListView {
                id: keyList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: root.filteredKeys()
                currentIndex: root.keyEntryIndex
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    id: keyRow
                    required property var modelData
                    required property int index
                    readonly property bool selected: keyList.currentIndex === index && root.keyPane === 1
                    width: keyList.width
                    height: 52
                    radius: 11
                    color: selected ? Theme.blueSoft : keyHover.hovered ? Theme.surfaceHigh : Theme.panel
                    border.width: 1
                    border.color: selected ? Theme.comet : keyHover.hovered ? Theme.blue : Theme.outline

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
                    TapHandler { onTapped: { root.keyEntryIndex = keyRow.index; root.keyPane = 1; } }
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
                    { label: "LOCK", detail: "secure session", command: ["qs", "-p", Quickshell.shellPath("lock.qml"), "-d"], colour: Theme.ice },
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
