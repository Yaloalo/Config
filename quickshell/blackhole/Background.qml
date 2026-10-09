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

            // Real-time analytical lensing model: Einstein deflection, a warped
            // star field, lensed accretion arcs, photon sphere and Doppler beaming.
            ShaderEffect {
                anchors.fill: parent
                property real time: window.simulationTime
                property vector2d resolution: Qt.vector2d(width, height)
                fragmentShader: Quickshell.shellPath("shaders/blackhole.frag.qsb")
            }

            Timer {
                interval: 33
                repeat: true
                running: ShellState.motionEnabled
                onTriggered: window.simulationTime += 0.033
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 22
                text: ShellState.motionEnabled ? "LENSING SIMULATION  /  ACTIVE" : "LENSING SIMULATION  /  FROZEN"
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 9
                font.letterSpacing: 1.4
            }
        }
    }
}
