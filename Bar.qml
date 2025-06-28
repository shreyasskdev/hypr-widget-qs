import Quickshell
import QtQuick
import "root:/components"
import "root:/config" // Import our new Theme singleton

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                bottom: true
            }
            implicitWidth: 40

            // Add a Rectangle for the background color
            Rectangle {
                id: backgroundRect
                anchors.fill: parent

                // Bind the color to the theme's background.
                // Use the helper function for transparency.
                // color: Theme.transparent(Theme.background, Theme.barAlpha)
                color: Theme.background
            }

            // The ClockWidget is placed on top of the background
            ClockWidget {
                anchors.centerIn: parent
            }
            BatteryWidget {
                anchors {
                    // 1. The vertical anchor (what you had)
                    bottom: parent.bottom

                    // 2. The missing horizontal anchor
                    horizontalCenter: parent.horizontalCenter

                    // 3. (Optional but recommended) Add a margin for spacing
                    bottomMargin: 10
                }
            }
        }
    }
}
