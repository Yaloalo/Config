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
            property real simulationTime: 0
            readonly property real renderScale: width > 2400 ? 0.50 : 0.68

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

            // A physically styled static frame is kept behind the shader so the
            // desktop still looks correct if the graphics backend is unavailable.
            Image {
                anchors.fill: parent
                source: Quickshell.shellPath("assets/black-hole.png")
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
            }

            // The geodesic integrator is deliberately expensive. Render it into
            // a smaller live texture, then let the GPU upscale it smoothly.
            Item {
                id: simulationBuffer
                width: Math.max(2, Math.ceil(window.width * window.renderScale))
                height: Math.max(2, Math.ceil(window.height * window.renderScale))

                ShaderEffect {
                    anchors.fill: parent
                    property real time: window.simulationTime
                    property vector2d resolution: Qt.vector2d(width, height)
                    fragmentShader: Quickshell.shellPath("shaders/blackhole.frag.qsb")
                }
            }

            ShaderEffectSource {
                anchors.fill: parent
                sourceItem: simulationBuffer
                textureSize: Qt.size(simulationBuffer.width, simulationBuffer.height)
                hideSource: true
                live: true
                recursive: true
                smooth: true
            }

            Timer {
                interval: 42
                repeat: true
                running: ShellState.motionEnabled
                onTriggered: window.simulationTime += 0.033
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 22
                text: ShellState.motionEnabled ? "GEODESIC SIMULATION  /  ACTIVE" : "GEODESIC SIMULATION  /  FROZEN"
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 9
                font.letterSpacing: 1.4
            }
        }
    }
}
