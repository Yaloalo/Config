pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notification => notification.tracked = true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            required property var modelData

            screen: modelData
            color: "transparent"
            implicitWidth: 390
            exclusiveZone: 0

            anchors {
                top: true
                right: true
                bottom: true
            }

            WlrLayershell.namespace: "blackhole-shell"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            mask: Region { item: cards }

            Column {
                id: cards
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 58
                anchors.rightMargin: 12
                width: 360
                spacing: 8

                Repeater {
                    model: server.trackedNotifications

                    Rectangle {
                        id: notificationCard
                        required property var modelData
                        width: cards.width
                        height: Math.max(92, content.implicitHeight + 28)
                        radius: 16
                        color: Theme.surfaceHigh
                        border.width: 1
                        border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.danger : Theme.outline
                        clip: true

                        SpaceField { preferences: Preferences; moving: ShellState.motionEnabled;
                            anchors.fill: parent
                            starCount: 24
                            seed: notificationCard.modelData.id ?? 9
                            strength: 0.56
                        }

                        RowLayout {
                            id: content
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            Image {
                                readonly property url resolvedIcon: notificationCard.modelData.image
                                    || (notificationCard.modelData.appIcon
                                        ? Quickshell.iconPath(notificationCard.modelData.appIcon)
                                        : "")
                                visible: resolvedIcon.toString().length > 0
                                source: resolvedIcon
                                sourceSize.width: 38
                                sourceSize.height: 38
                                Layout.preferredWidth: visible ? 40 : 0
                                Layout.preferredHeight: 40
                                fillMode: Image.PreserveAspectFit
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3
                                Text { text: notificationCard.modelData.appName || "System"; color: Theme.blue; font.family: Theme.font; font.pixelSize: 9; font.bold: true }
                                Text { text: notificationCard.modelData.summary; color: Theme.text; font.family: Theme.font; font.pixelSize: 11; font.bold: true; wrapMode: Text.Wrap; Layout.fillWidth: true }
                                Text { visible: text.length > 0; text: notificationCard.modelData.body; color: Theme.muted; font.family: Theme.font; font.pixelSize: 9; textFormat: Text.PlainText; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight; Layout.fillWidth: true }
                            }

                            Text { text: "×"; color: Theme.ice; font.pixelSize: 17; Layout.alignment: Qt.AlignTop }
                        }

                        TapHandler { onTapped: notificationCard.modelData.dismiss() }

                        Timer {
                            interval: notificationCard.modelData.expireTimeout > 0 ? notificationCard.modelData.expireTimeout : 6500
                            running: true
                            onTriggered: notificationCard.modelData.expire()
                        }
                    }
                }
            }
        }
    }
}
