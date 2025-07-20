import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications

import "root:/config"

PanelWindow {
    id: window
    implicitWidth: 400
    // Fixed height to prevent any window size animations
    implicitHeight: 600

    anchors {
        top: true
        right: true
    }

    // Make window completely transparent and non-interactive when empty
    color: "transparent"
    visible: notificationModel.count > 0

    // The NotificationServer listens for notifications from the system.
    NotificationServer {
        id: server
        onNotification: notif => {
            // When a notification is received, add it to our list.
            notificationModel.append({
                summary: notif.summary,
                body: notif.body,
                appName: notif.appName,
                appIcon: notif.appIcon,
                // Use the notification's timeout, or a default of 5 seconds.
                expireTimeout: notif.expireTimeout > 0 ? notif.expireTimeout : 5000
            });
        }
    }

    // This model will store the list of active notifications.
    ListModel {
        id: notificationModel
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 10

        // Keep interaction disabled to prevent conflicts
        interactive: false

        model: notificationModel
        delegate: notificationDelegate
        spacing: 10
        clip: true
        verticalLayoutDirection: ListView.TopToBottom

        // Smooth transitions for adding/removing items
        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        remove: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 250
                easing.type: Easing.InQuad
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        removeDisplaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
    }

    // This component defines the UI for a single notification.
    Component {
        id: notificationDelegate

        Item {
            id: notificationItem
            implicitWidth: listView.width
            implicitHeight: Math.max(80, contentContainer.implicitHeight + 20)

            Item {
                id: container
                anchors.fill: parent
                property real blurAmount: 2.5
                scale: 0.3

                transformOrigin: Item.TopRight

                Rectangle {
                    id: backgroundBox
                    anchors.fill: parent
                    color: Theme.background
                    border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.3)
                    border.width: 2
                    radius: 20

                    Row {
                        id: contentContainer
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 12

                        Image {
                            id: appIcon
                            width: 48
                            height: 48
                            anchors.verticalCenter: parent.verticalCenter
                            source: model.appIcon ? model.appIcon : ""
                            fillMode: Image.PreserveAspectFit

                            // Add fallback for missing icons
                            Rectangle {
                                anchors.fill: parent
                                color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.2)
                                radius: 8
                                visible: appIcon.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: model.appName ? model.appName.charAt(0).toUpperCase() : "N"
                                    color: Theme.foreground
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        Column {
                            id: textColumn
                            width: parent.width - appIcon.width - parent.spacing
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Text {
                                id: summaryText
                                width: parent.width
                                text: model.summary || ""
                                color: Theme.foreground
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight

                                font {
                                    pixelSize: 15
                                    weight: Font.Bold
                                    family: "CaskaydiaCove NF"
                                }
                            }

                            Text {
                                id: bodyText
                                width: parent.width
                                text: model.body || ""
                                color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.8)
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight

                                font {
                                    pixelSize: 13
                                    family: "CaskaydiaCove NF"
                                }
                            }
                        }
                    }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: container.blurAmount
                    blurMax: 32
                }

                // Entrance animation
                SequentialAnimation {
                    id: scaleAnimation
                    ParallelAnimation {
                        NumberAnimation {
                            target: container
                            property: "scale"
                            to: 1.0
                            duration: 300
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: container
                            property: "blurAmount"
                            to: 0.0
                            duration: 500
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                // Exit animation
                SequentialAnimation {
                    id: exitAnimation
                    ParallelAnimation {
                        NumberAnimation {
                            target: container
                            property: "scale"
                            to: 0.0
                            duration: 500
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            target: container
                            property: "blurAmount"
                            to: 2.5
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                    }
                    onFinished: {
                        if (model.index >= 0 && model.index < notificationModel.count) {
                            notificationModel.remove(model.index);
                        }
                    }
                }
            }

            Timer {
                interval: model.expireTimeout
                running: true
                onTriggered: {
                    exitAnimation.start();
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    exitAnimation.start();
                }
                cursorShape: Qt.PointingHandCursor
            }
            Component.onCompleted: {
                scaleAnimation.restart();
            }
        }
    }
}
