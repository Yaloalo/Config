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
            property real phase: 0
            readonly property real blend: 0.5 + 0.5 * Math.sin(phase)

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

            // Two matched frames drift and dissolve into one another. This moves
            // the whole scene instead of drawing an effect over a still image.
            Item {
                anchors.fill: parent
                clip: true

                Image {
                    x: -parent.width * 0.07 + Math.sin(window.phase * 0.7) * parent.width * 0.018
                    y: -parent.height * 0.07 + Math.cos(window.phase * 0.5) * parent.height * 0.012
                    width: parent.width * 1.14
                    height: parent.height * 1.14
                    source: Quickshell.shellPath("assets/black-hole.png")
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                    opacity: 1 - window.blend * 0.62
                    rotation: Math.sin(window.phase * 0.33) * 0.32
                    transformOrigin: Item.Center
                }

                Image {
                    x: -parent.width * 0.075 + Math.cos(window.phase * 0.62) * parent.width * 0.016
                    y: -parent.height * 0.075 + Math.sin(window.phase * 0.44) * parent.height * 0.013
                    width: parent.width * 1.15
                    height: parent.height * 1.15
                    source: Quickshell.shellPath("assets/black-hole-evolved.png")
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                    opacity: window.blend * 0.62
                    rotation: -Math.cos(window.phase * 0.29) * 0.28
                    transformOrigin: Item.Center
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#160b0500"
                }
            }

            Timer {
                interval: 40
                repeat: true
                running: ShellState.motionEnabled
                onTriggered: window.phase = (window.phase + 0.0025) % (Math.PI * 2)
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 24
                text: ShellState.motionEnabled ? "◌  EVENT HORIZON IN MOTION" : "◉  EVENT HORIZON FROZEN"
                color: "#99d49a63"
                font.family: Theme.font
                font.pixelSize: 10
                font.letterSpacing: 1.1
            }
        }
    }
}
