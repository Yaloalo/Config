pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import qs.common
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    id: root
    clip: true
    palette.window: Theme.onFg
    palette.windowText: Theme.fg
    palette.text: Theme.fg
    palette.button: Theme.voidBlack
    palette.buttonText: Theme.fg
    palette.highlight: Theme.edgeHi
    contentWidth: availableWidth
    component SpaceSwitch: Switch {
        id: toggle
        implicitHeight: 38
        spacing: 12
        indicator: Rectangle {
            x: toggle.leftPadding
            y: (toggle.height - height) / 2
            width: 36; height: 20; radius: Theme.r(10)
            color: toggle.checked ? Theme.fill : Theme.glass
            border.color: toggle.checked ? Theme.edgeHi : Theme.edge
            Rectangle {
                x: toggle.checked ? 19 : 3; y: 3
                width: 14; height: 14; radius: Theme.r(7)
                color: toggle.checked ? Theme.fg : Theme.knobOff
                Behavior on x { NumberAnimation { duration: 120 } }
            }
        }
        contentItem: Text {
            text: toggle.text
            leftPadding: 48
            verticalAlignment: Text.AlignVCenter
            color: Theme.fg; font.family: Theme.font; font.pixelSize: Theme.fs(11)
        }
    }
    ColumnLayout {
        width: root.availableWidth
        spacing: 12
        Text { text: "THEME"; color: Theme.fg; font.family: Theme.font; font.bold: true; font.pixelSize: Theme.fs(11) }
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Repeater {
                model: [
                    { mode: "star", label: "STAR", sub: "deep space" },
                    { mode: "eva", label: "EVA", sub: "NERV / MAGI" }
                ]
                Button {
                    id: modeButton
                    required property var modelData
                    readonly property bool selected: Mode.mode === modelData.mode
                    Layout.fillWidth: true
                    implicitHeight: 54
                    hoverEnabled: true
                    background: Rectangle {
                        radius: Theme.r(12)
                        color: modeButton.selected ? Theme.fill : Theme.glass
                        border.width: modeButton.selected ? 2 : 1
                        border.color: modeButton.selected ? Theme.ice : modeButton.hovered || modeButton.activeFocus ? Theme.edgeHi : Theme.edge
                        clip: true
                        SpaceField {
                            anchors.fill: parent; anchors.margins: 5
                            visible: modeButton.modelData.mode === "star"
                            preferences: Preferences; moving: ShellState.motionEnabled; starCount: 16; strength: .45
                        }
                        Image {
                            anchors.fill: parent
                            visible: modeButton.modelData.mode === "eva"
                            source: Nerv.assets + "/hex.png"; fillMode: Image.Tile; opacity: 0.8
                        }
                    }
                    contentItem: Column {
                        spacing: 2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modeButton.modelData.label
                            color: modeButton.modelData.mode === "eva" ? Nerv.orange : "white"
                            font.family: modeButton.modelData.mode === "eva" ? Nerv.sans : "JetBrainsMono Nerd Font"
                            font.pixelSize: modeButton.modelData.mode === "eva" ? 18 : 13
                            font.bold: true
                            font.letterSpacing: 2
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modeButton.modelData.sub
                            color: modeButton.modelData.mode === "eva" ? Nerv.amber : "#8190a5"
                            font.family: modeButton.modelData.mode === "eva" ? Nerv.sans : "JetBrainsMono Nerd Font"
                            font.pixelSize: modeButton.modelData.mode === "eva" ? 13 : 9
                        }
                    }
                    onClicked: ShellState.setMode(modelData.mode)
                }
            }
        }
        Text {
            text: "Switches desktop, terminal, lock screen, login screen, boot splash and boot menu."
            color: Theme.muted; font.family: Theme.font; font.pixelSize: Theme.fs(10)
            wrapMode: Text.Wrap; Layout.fillWidth: true
        }
        Button {
            id: guideButton
            text: "Keybindings  ·  Super G"
            Layout.fillWidth: true
            implicitHeight: 42
            hoverEnabled: true
            background: Rectangle {
                radius: Theme.r(12); color: Theme.glass
                border.color: guideButton.hovered || guideButton.activeFocus ? Theme.fg : Theme.edge
                SpaceField { anchors.fill: parent; anchors.margins: 5; preferences: Preferences; moving: ShellState.motionEnabled; starCount: 16; strength: .35 }
            }
            contentItem: Text {
                text: guideButton.text; color: Theme.fg
                font.family: Theme.font; font.pixelSize: Theme.fs(11)
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
            }
            onClicked: ShellState.overlay = "keybinds"
        }
        SpaceSwitch {
            text: "Moving stars  ·  Super Pause"
            checked: ShellState.motionEnabled
            onToggled: {
                Preferences.starsPaused = !checked;
                Preferences.save();
            }
        }
        SpaceSwitch {
            text: "Eco mode"
            checked: Preferences.ecoMode
            onToggled: { Preferences.ecoMode = checked; Preferences.applyEco(); }
        }
        Text {
            text: Preferences.status || "Eco saves the current brightness and effects, then restores them when disabled."
            color: Theme.muted; font.family: Theme.font; font.pixelSize: Theme.fs(10)
            wrapMode: Text.Wrap; Layout.fillWidth: true
        }
        Repeater {
            model: [
                {key: "ecoPauseStars", label: "Eco: freeze star animation"},
                {key: "ecoDisableBlur", label: "Eco: disable compositor blur"},
                {key: "ecoDisableAnimations", label: "Eco: disable window animations"},
                {key: "warpMode", label: "Warp speed (desktop stars)"},
                {key: "thermalSpeed", label: "Desktop stars speed up with CPU temp and fans"}
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
        Text {
            visible: Preferences.thermalSpeed
            text: !ThermalState.available ? "Reading sensors…"
                : Math.round(ThermalState.temp) + " °C" + (ThermalState.hasFan ? "  ·  fan " + Math.round(ThermalState.fan) + " rpm" : "  ·  no fan sensor")
                  + "  →  " + (0.5 + ThermalState.heat * 3.5).toFixed(1) + "× speed"
            color: Theme.muted; font.family: Theme.font; font.pixelSize: Theme.fs(10)
            Layout.fillWidth: true
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
                Text { text: setting.modelData.label + "  " + Preferences[setting.modelData.key]; color: Theme.fg; font.family: Theme.font; font.pixelSize: Theme.fs(10) }
                Slider {
                    id: slider
                    Layout.fillWidth: true
                    implicitHeight: 28
                    background: Rectangle {
                        x: slider.leftPadding; y: (slider.height-height)/2
                        width: slider.availableWidth; height: 3; radius: Theme.r(2); color: Theme.fill
                        Rectangle { width: slider.visualPosition * parent.width; height: parent.height; radius: Theme.r(2); color: Theme.accentFill }
                    }
                    handle: Rectangle {
                        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth-width)
                        y: (slider.height-height)/2
                        width: 12; height: 12; radius: Theme.r(6)
                        color: slider.pressed ? Theme.fg : Theme.accentFill
                    }
                    from: setting.modelData.min; to: setting.modelData.max; stepSize: setting.modelData.step
                    value: Preferences[setting.modelData.key]
                    onMoved: { Preferences[setting.modelData.key] = value; Preferences.save(); }
                    onPressedChanged: if (!pressed && Preferences.ecoMode && setting.modelData.key === "ecoBrightness") Preferences.applyEco()
                }
            }
        }
        Text { text: "DEVICE SETTINGS"; color: Theme.fg; font.family: Theme.font; font.bold: true; Layout.topMargin: 12 }
        GridLayout {
            columns: 2; Layout.fillWidth: true
            columnSpacing: 10; rowSpacing: 10
            Repeater {
                model: [
                    {label: "Wi-Fi", panel: "wifi"},
                    {label: "Displays / scale / mirror", command: ["python3", Quickshell.shellPath("../../scripts/space-displays.py")]},
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
                        radius: Theme.r(12)
                        color: deviceButton.down ? Theme.glassDown : deviceButton.hovered ? Theme.glassHover : Theme.glass
                        border.color: deviceButton.hovered || deviceButton.activeFocus ? Theme.accentFill : Theme.edge
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                        SpaceField {
                            anchors.fill: parent; anchors.margins: 5
                            preferences: Preferences; moving: ShellState.motionEnabled
                            starCount: 12; strength: .35
                        }
                    }
                    contentItem: Text {
                        text: deviceButton.text
                        color: Theme.fg; font.family: Theme.font; font.pixelSize: Theme.fs(10)
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
            text: "Manual lock: Super + Escape. Type your password and press Enter on the star screen.\nLid close locks before suspending. Automatic idle locking is disabled."
            color: Theme.muted; font.family: Theme.font; font.pixelSize: Theme.fs(10)
            wrapMode: Text.Wrap; Layout.fillWidth: true
        }
    }
}
