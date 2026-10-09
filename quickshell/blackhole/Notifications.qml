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

                        RowLayout {
                            id: content
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            Image {
                                visible: source.toString().length > 0
                                source: notificationCard.modelData.image || Quickshell.iconPath(notificationCard.modelData.appIcon, "dialog-information")
                                sourceSize.width: 38
                                sourceSize.height: 38
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                fillMode: Image.PreserveAspectFit
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3
                                Text { text: notificationCard.modelData.appName || "System"; color: Theme.amber; font.family: Theme.font; font.pixelSize: 9; font.bold: true }
                                Text { text: notificationCard.modelData.summary; color: Theme.text; font.family: Theme.font; font.pixelSize: 11; font.bold: true; wrapMode: Text.Wrap; Layout.fillWidth: true }
                                Text { visible: text.length > 0; text: notificationCard.modelData.body; color: Theme.muted; font.family: Theme.font; font.pixelSize: 9; textFormat: Text.PlainText; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight; Layout.fillWidth: true }
                            }

                            Text { text: "×"; color: Theme.gold; font.pixelSize: 17; Layout.alignment: Qt.AlignTop }
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
