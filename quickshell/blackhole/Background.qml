pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.common

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            required property var modelData

            screen: modelData
            color: Theme.voidBlack
            exclusiveZone: 0

            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }

            WlrLayershell.namespace: "blackhole-background"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            Rectangle {
                anchors.fill: parent
                color: Theme.voidBlack
            }

            // The desktop and shell surfaces now share one visual language: an
            // unbounded, sparse field with slow parallax and no central object.
            SpaceField { preferences: Preferences; moving: ShellState.motionEnabled;
                anchors.fill: parent
                starModes: true
                heat: Preferences.thermalSpeed && ThermalState.available ? ThermalState.heat : -1
                starCount: 320
                seed: 3
                strength: 0.55
                tint: Theme.ice
            }

            SpaceField { preferences: Preferences; moving: ShellState.motionEnabled;
                anchors.fill: parent
                starModes: true
                heat: Preferences.thermalSpeed && ThermalState.available ? ThermalState.heat : -1
                starCount: 96
                seed: 47
                strength: 0.42
                tint: Theme.eva ? Nerv.amber : Theme.blue
            }

            // Eva mode turns the desktop into a NERV standby terminal: hex grid,
            // a faint 待機 watermark, a hazard stripe and a MAGI lamp bank.
            Item {
                anchors.fill: parent
                visible: Theme.eva
                Image { anchors.fill: parent; source: Nerv.assets + "/hex.png"; fillMode: Image.Tile; opacity: 0.7 }
                NervSquash {
                    x: 60
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 30
                    size: parent.height * 0.3
                    text: "待機"
                    color: Nerv.line
                    opacity: 0.55
                }
                Item {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 8
                    clip: true
                    Image { width: parent.width; height: 32; source: Nerv.assets + "/hazard-orange.png"; fillMode: Image.Tile }
                }
                LampBank {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 22
                    anchors.bottomMargin: 62
                    columns: 10
                    count: 30
                    cellWidth: 18
                    cellHeight: 7
                    spacing: 4
                    tone: ShellState.motionEnabled ? "idle" : "deny"
                }
                Image { anchors.fill: parent; source: Nerv.assets + "/scan.png"; fillMode: Image.Tile; opacity: 0.35 }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 22
                width: deepFieldLabel.implicitWidth + 22
                height: Theme.eva ? 30 : 26
                radius: Theme.r(9)
                color: Theme.panel
                border.color: Theme.eva ? Nerv.orange : Theme.outline
                border.width: Theme.eva ? 2 : 1
                clip: true

                SpaceField { preferences: Preferences; moving: ShellState.motionEnabled; anchors.fill: parent; starCount: 8; seed: 81; strength: 0.5 }

                Text {
                    id: deepFieldLabel
                    anchors.centerIn: parent
                    text: (Theme.eva ? "MAGI  /  " : "DEEP FIELD  /  ") + (!ShellState.motionEnabled ? "STILL" : Preferences.warpMode ? "WARP" : "DRIFT")
                        + (Preferences.thermalSpeed && ThermalState.available ? "  /  " + Math.round(ThermalState.temp) + "°C" : "")
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.fs(9)
                    font.letterSpacing: 1.4
                }
            }
        }
    }
}
