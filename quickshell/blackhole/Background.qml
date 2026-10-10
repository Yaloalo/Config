pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

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
                starCount: 320
                seed: 3
                strength: 0.55
                tint: Theme.ice
            }

            SpaceField { preferences: Preferences; moving: ShellState.motionEnabled;
                anchors.fill: parent
                starCount: 96
                seed: 47
                strength: 0.42
                tint: Theme.blue
            }

            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 22
                width: deepFieldLabel.implicitWidth + 22
                height: 26
                radius: 9
                color: Theme.panel
                border.width: 1
                border.color: Theme.outline
                clip: true

                SpaceField { preferences: Preferences; moving: ShellState.motionEnabled; anchors.fill: parent; starCount: 8; seed: 81; strength: 0.5 }

                Text {
                    id: deepFieldLabel
                    anchors.centerIn: parent
                    text: ShellState.motionEnabled ? "DEEP FIELD  /  DRIFT" : "DEEP FIELD  /  STILL"
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 9
                    font.letterSpacing: 1.4
                }
            }
        }
    }
}
