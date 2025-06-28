import QtQuick
import "root:/config" // Import our new Theme singleton
import "Time.qml"

Item {
    implicitHeight: 120
    implicitWidth: Math.max(hours.implicitWidth, Math.max(colon.implicitWidth, Math.max(minutes.implicitWidth, ampm.implicitWidth)))

    readonly property font clockFont: Qt.font({
        family: "Electroharmonix",
        pixelSize: 20,
        weight: 900
    })

    readonly property font ampmFont: Qt.font({
        family: "Electroharmonix",
        pixelSize: 15,
        weight: 900
    })

    // --- Bind all text colors directly to the theme's foreground color ---

    Text {
        id: hours
        text: Time.hours
        color: Theme.foreground // Use the theme color
        font: parent.clockFont
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        renderType: Text.NativeRendering
    }

    Text {
        id: colon
        text: ":"
        color: Theme.foreground // Use the theme color
        font: parent.clockFont
        anchors.horizontalCenter: parent.horizontalCenter
        rotation: 90
        y: hours.y + hours.height - 3
        renderType: Text.NativeRendering
    }

    Text {
        id: minutes
        text: Time.minutes
        // Let's use an accent color for the minutes for fun!
        // Pywal's color4 is often a nice blue/accent.
        color: Theme.colors[4]
        font: parent.clockFont
        anchors.horizontalCenter: parent.horizontalCenter
        y: colon.y + colon.height - 5
        renderType: Text.NativeRendering
    }

    Text {
        id: ampm
        text: Time.ampm
        color: Theme.foreground // Use the theme color
        font: parent.ampmFont
        anchors.horizontalCenter: parent.horizontalCenter
        height: 30
        y: minutes.y + minutes.height + 5
        renderType: Text.NativeRendering
    }
}
