pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: 12
    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    function submit() { WifiState.connect(password.text); password.clear(); }
    component SpaceButton: Button {
        id: button
        implicitHeight: 34
        hoverEnabled: true
        background: Rectangle {
            radius: 9; color: button.down ? "#242424" : "#b0000000"
            border.color: button.hovered || button.activeFocus ? "white" : "#555555"
            opacity: button.enabled ? 1 : .4
        }
        contentItem: Text {
            text: button.text; color: button.enabled ? "white" : "#777777"
            font.family: Theme.font; font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        }
    }
    component SpaceCheck: CheckBox {
        id: check
        implicitHeight: 30
        indicator: Rectangle {
            x: 0; y: (check.height-height)/2
            width: 18; height: 18; radius: 5
            color: check.checked ? "white" : "black"
            border.color: check.activeFocus ? "white" : "#777777"
            Text { anchors.centerIn: parent; text: check.checked ? "✓" : ""; color: "black"; font.pixelSize: 12 }
        }
        contentItem: Text {
            text: check.text; leftPadding: 28; color: "white"
            font.family: Theme.font; font.pixelSize: 10; verticalAlignment: Text.AlignVCenter
        }
    }
    RowLayout {
        Layout.fillWidth: true
        StatusIcon { kind: "wifi"; Layout.preferredWidth: 24; Layout.preferredHeight: 24 }
        Text { text: Networking.wifiEnabled ? "Wi-Fi on" : "Wi-Fi off"; color: "white"; font.family: Theme.font; Layout.fillWidth: true }
        SpaceButton { text: Networking.wifiEnabled ? "Turn off" : "Turn on"; Layout.preferredWidth: 110; onClicked: Networking.wifiEnabled = !Networking.wifiEnabled }
    }
    Rectangle {
        visible: WifiState.selected !== null && Networking.wifiEnabled
        Layout.fillWidth: true
        implicitHeight: details.implicitHeight + 28
        radius: 13; color: Theme.panel; border.color: "#777777"
        ColumnLayout {
            id: details
            anchors.fill: parent; anchors.margins: 14; spacing: 8
            Text {
                text: WifiState.selected?.name ?? ""
                Layout.fillWidth: true; elide: Text.ElideRight
                color: "white"; font.family: Theme.font; font.bold: true; font.pixelSize: 12
            }
            Text {
                text: WifiState.advanced ? "This network needs advanced authentication. Open Network connections to configure it."
                    : WifiState.message || (WifiState.selected?.connected ? "Connected" : WifiState.askPassword ? "Enter the network security key" : WifiState.openNetwork ? "No password required" : "Saved credentials will be used")
                Layout.fillWidth: true; wrapMode: Text.Wrap
                color: Theme.muted; font.family: Theme.font; font.pixelSize: 10
            }
            TextField {
                id: password
                visible: WifiState.askPassword && !WifiState.advanced && !WifiState.selected?.connected
                Layout.fillWidth: true; implicitHeight: 38
                placeholderText: "Wi-Fi password"; color: "white"; placeholderTextColor: "#888888"
                echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                font.family: Theme.font; font.pixelSize: 11
                background: Rectangle { radius: 9; color: "black"; border.color: password.activeFocus ? "white" : "#555555" }
                onAccepted: root.submit()
                onVisibleChanged: if (visible) forceActiveFocus()
            }
            SpaceCheck { id: showPassword; text: "Show password"; visible: password.visible }
            RowLayout {
                Layout.fillWidth: true
                SpaceCheck {
                    text: "Connect automatically"; checked: WifiState.autoConnect
                    enabled: !WifiState.busy && !WifiState.policyNetwork
                    onToggled: {
                        WifiState.autoConnect = checked;
                        if (WifiState.selected?.connected) WifiState.savePolicy(WifiState.selected, checked);
                    }
                }
                Item { Layout.fillWidth: true }
                SpaceButton {
                    text: "Cancel"; Layout.preferredWidth: 85
                    onClicked: { password.clear(); WifiState.selected = null; }
                }
                SpaceButton {
                    text: WifiState.advanced ? "Configure" : WifiState.busy ? "Connecting…" : WifiState.selected?.connected ? "Disconnect" : "Connect"
                    Layout.preferredWidth: 110; enabled: !WifiState.busy
                    onClicked: {
                        if (WifiState.advanced) Quickshell.execDetached(["nm-connection-editor"]);
                        else if (WifiState.selected?.connected) { WifiState.message = ""; WifiState.selected.disconnect(); }
                        else root.submit();
                    }
                }
            }
        }
    }
    ListView {
        id: networks
        Layout.fillWidth: true; Layout.fillHeight: true
        clip: true; spacing: 8
        model: Networking.wifiEnabled ? (root.device?.networks.values ?? []).slice().sort((a, b) =>
            Number(b.connected) - Number(a.connected) || b.signalStrength - a.signalStrength || a.name.localeCompare(b.name)) : []
        delegate: Rectangle {
            id: row
            required property var modelData
            width: networks.width; height: 64; radius: 12
            color: hover.hovered ? "#d0000000" : Theme.panel
            border.color: WifiState.selected === modelData ? "white" : "#404040"
            RowLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 12
                StatusIcon { kind: "wifi"; Layout.preferredWidth: 24; Layout.preferredHeight: 24 }
                ColumnLayout {
                    Layout.fillWidth: true; Layout.minimumWidth: 0; spacing: 3
                    Text {
                        text: row.modelData.name || "Hidden network"
                        Layout.fillWidth: true; elide: Text.ElideRight
                        color: "white"; font.family: Theme.font; font.pixelSize: 11
                    }
                    Text {
                        text: row.modelData.connected ? "Connected" : row.modelData.stateChanging ? "Connecting…" : row.modelData.known ? "Saved" : WifiSecurityType.toString(row.modelData.security)
                        Layout.fillWidth: true; elide: Text.ElideRight
                        color: Theme.muted; font.family: Theme.font; font.pixelSize: 9
                    }
                }
                Text {
                    text: Math.round(row.modelData.signalStrength * 100) + "%"
                    Layout.minimumWidth: 40; Layout.maximumWidth: 40; Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight; color: Theme.muted; font.family: Theme.font; font.pixelSize: 9
                }
                SpaceButton {
                    text: row.modelData.connected ? "Connected" : "Select"
                    Layout.minimumWidth: 100; Layout.maximumWidth: 100; Layout.preferredWidth: 100
                    enabled: !WifiState.busy && !WifiState.policyNetwork
                    onClicked: { password.clear(); showPassword.checked = false; WifiState.select(row.modelData); }
                }
            }
            HoverHandler { id: hover }
            TapHandler { onTapped: { password.clear(); showPassword.checked = false; WifiState.select(row.modelData); } }
        }
        Text {
            anchors.centerIn: parent
            visible: networks.count === 0
            text: !root.device ? "No wireless adapter found" : !Networking.wifiEnabled ? "Wi-Fi is turned off" : "Scanning for networks…"
            color: Theme.muted; font.family: Theme.font; font.pixelSize: 11
        }
    }
    Component.onDestruction: password.clear()
}
