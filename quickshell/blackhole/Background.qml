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
            updatesEnabled: ShellState.motionEnabled

            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }

            WlrLayershell.namespace: "blackhole-background"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            Image {
                anchors.fill: parent
                source: Quickshell.shellPath("assets/black-hole.png")
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
            }

            Rectangle {
                anchors.fill: parent
                color: "#18070a18"
            }

            // Lightweight accretion-disk highlights make the black hole feel alive.
            Canvas {
                id: accretion
                property real phase: 0

                x: parent.width * 0.05
                y: parent.height * 0.13
                width: parent.width * 0.58
                height: parent.height * 0.72
                opacity: 0.36

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.translate(width * 0.5, height * 0.5);
                    ctx.rotate(-0.08);
                    const colours = [Theme.cyan, Theme.violet, Theme.pink];
                    for (let ring = 0; ring < 3; ring++) {
                        ctx.beginPath();
                        ctx.strokeStyle = colours[ring];
                        ctx.globalAlpha = 0.22 - ring * 0.04;
                        ctx.lineWidth = 1.6 - ring * 0.3;
                        const radius = width * (0.28 + ring * 0.055);
                        for (let step = 0; step < 54; step++) {
                            const angle = phase + ring * 1.7 + step * 0.22;
                            const x = Math.cos(angle) * radius;
                            const y = Math.sin(angle) * radius * 0.24;
                            const arc = 3 + 8 * (0.5 + 0.5 * Math.sin(angle * 3));
                            ctx.moveTo(x, y);
                            ctx.arc(x, y, arc, 0, Math.PI * 1.2);
                        }
                        ctx.stroke();
                    }
                }

                Timer {
                    interval: 40
                    repeat: true
                    running: ShellState.motionEnabled
                    onTriggered: {
                        accretion.phase += 0.006;
                        accretion.requestPaint();
                    }
                }
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 24
                text: ShellState.motionEnabled ? "◌  accretion active" : "◉  spacetime paused"
                color: "#77938eae"
                font.family: Theme.font
                font.pixelSize: 11
            }
        }
    }
}
