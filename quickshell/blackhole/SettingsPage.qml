pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    id: root
    clip: true
    palette.window: "black"
    palette.windowText: "white"
    palette.text: "white"
    palette.button: "#000000"
    palette.buttonText: "white"
    palette.highlight: "#aaaaaa"
    contentWidth: availableWidth
    component SpaceSwitch: Switch {
        id: toggle
        implicitHeight: 38
        spacing: 12
        indicator: Rectangle {
            x: toggle.leftPadding
            y: (toggle.height - height) / 2
            width: 36; height: 20; radius: 10
            color: toggle.checked ? "#303030" : "#080808"
            border.color: toggle.checked ? "#aaaaaa" : "#444444"
            Rectangle {
                x: toggle.checked ? 19 : 3; y: 3
                width: 14; height: 14; radius: 7
                color: toggle.checked ? "white" : "#666666"
                Behavior on x { NumberAnimation { duration: 120 } }
            }
        }
        contentItem: Text {
            text: toggle.text
            leftPadding: 48
            verticalAlignment: Text.AlignVCenter
            color: "white"; font.family: Theme.font; font.pixelSize: 11
        }
    }
    ColumnLayout {
        width: root.availableWidth
        spacing: 12
        SpaceSwitch {
            text: "Eco mode"
            checked: Preferences.ecoMode
            onToggled: { Preferences.ecoMode = checked; Preferences.applyEco(); }
        }
        Text {
            text: Preferences.status || "Eco saves the current brightness and effects, then restores them when disabled."
            color: Theme.muted; font.family: Theme.font; font.pixelSize: 10
            wrapMode: Text.Wrap; Layout.fillWidth: true
        }
        Repeater {
            model: [
                {key: "ecoPauseStars", label: "Eco: freeze star animation"},
                {key: "ecoDisableBlur", label: "Eco: disable compositor blur"},
                {key: "ecoDisableAnimations", label: "Eco: disable window animations"},
                {key: "focusComet", label: "Yellow focus trail"}
            ]
            SpaceSwitch {
                required property var modelData
                text: modelData.label
                checked: Preferences[modelData.key]
                onToggled: {
                    Preferences[modelData.key] = checked;
                    Preferences.save();
                    if (Preferences.ecoMode) Preferences.applyEco();
                }
            }
        }
        Repeater {
            model: [
                {key: "ecoBrightness", label: "Eco brightness (%)", min: 5, max: 100, step: 5},
                {key: "starDensity", label: "Star density", min: .5, max: 3, step: .25},
                {key: "starSpeed", label: "Star speed", min: .25, max: 2, step: .25}
            ]
            ColumnLayout {
                id: setting
                required property var modelData
                Layout.fillWidth: true
                Text { text: setting.modelData.label + "  " + Preferences[setting.modelData.key]; color: "white"; font.family: Theme.font; font.pixelSize: 10 }
                Slider {
                    id: slider
                    Layout.fillWidth: true
                    implicitHeight: 28
                    background: Rectangle {
                        x: slider.leftPadding; y: (slider.height-height)/2
                        width: slider.availableWidth; height: 3; radius: 2; color: "#303030"
                        Rectangle { width: slider.visualPosition * parent.width; height: parent.height; radius: 2; color: "#cccccc" }
                    }
                    handle: Rectangle {
                        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth-width)
                        y: (slider.height-height)/2
                        width: 12; height: 12; radius: 6
                        color: slider.pressed ? "white" : "#cccccc"
                    }
                    from: setting.modelData.min; to: setting.modelData.max; stepSize: setting.modelData.step
                    value: Preferences[setting.modelData.key]
                    onMoved: { Preferences[setting.modelData.key] = value; Preferences.save(); }
                    onPressedChanged: if (!pressed && Preferences.ecoMode && setting.modelData.key === "ecoBrightness") Preferences.applyEco()
                }
            }
        }
        Text { text: "DEVICE SETTINGS"; color: "white"; font.family: Theme.font; font.bold: true; Layout.topMargin: 12 }
        GridLayout {
            columns: 2; Layout.fillWidth: true
            columnSpacing: 10; rowSpacing: 10
            Repeater {
                model: [
                    {label: "Wi-Fi", panel: "wifi"},
                    {label: "Displays / scale / mirror", command: ["nwg-displays"]},
                    {label: "Audio inputs and outputs", command: ["pavucontrol"]},
                    {label: "Bluetooth", command: ["blueman-manager"]},
                    {label: "Network connections", command: ["nm-connection-editor"]},
                    {label: "Session and power", panel: "power"}
                ]
                Button {
                    id: deviceButton
                    required property var modelData
                    text: modelData.label; Layout.fillWidth: true
                    implicitHeight: 46
                    hoverEnabled: true
                    background: Rectangle {
                        radius: 12
                        color: deviceButton.down ? "#ee000000" : deviceButton.hovered ? "#d8000000" : "#b0000000"
                        border.color: deviceButton.hovered || deviceButton.activeFocus ? "#cccccc" : "#444444"
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                        SpaceField {
                            anchors.fill: parent; anchors.margins: 5
                            preferences: Preferences; moving: ShellState.motionEnabled
                            starCount: 12; strength: .35
                        }
                    }
                    contentItem: Text {
                        text: deviceButton.text
                        color: "white"; font.family: Theme.font; font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    onClicked: {
                        if (modelData.panel) ShellState.overlay = modelData.panel;
                        else { Quickshell.execDetached(modelData.command); ShellState.close(); }
                    }
                }
            }
        }
        Text {
            text: "Manual lock: Super + Escape. Type your password and press Enter on the star screen.\nLid close suspends. Automatic idle locking is disabled."
            color: Theme.muted; font.family: Theme.font; font.pixelSize: 10
            wrapMode: Text.Wrap; Layout.fillWidth: true
        }
    }
}
