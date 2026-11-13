/*
 * Duneglow Clock plasmoid. GPL-3.0-or-later.
 * Big clock + date, no panel background. Colour is a mountain shade
 * (day #7F95AE, night #7C93B8; night = 18:00-05:59, same rule as the login screen).
 * Written without a Qt runtime available to the author: UNTESTED.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property date now: new Date()
    readonly property bool night: now.getHours() >= 18 || now.getHours() < 6
    readonly property color shade: night ? "#7C93B8" : "#7F95AE"

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.now = new Date()
    }

    FontLoader { id: fontClock; source: "../fonts/InterDisplay-Bold.otf" }
    FontLoader { id: fontSemi;  source: "../fonts/Inter-SemiBold.otf" }

    fullRepresentation: Item {
        id: face
        Layout.minimumWidth: 220
        Layout.minimumHeight: 120
        Layout.preferredWidth: 520
        Layout.preferredHeight: 260

        // Scale the text with the widget so it can be resized freely.
        readonly property real unit: Math.min(width / 3.2, height / 1.6)

        Column {
            anchors.centerIn: parent
            spacing: face.unit * 0.02

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(root.now, "hh:mm")
                color: root.shade
                font.family: fontClock.name
                font.pixelSize: face.unit
                renderType: Text.NativeRendering
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(root.now, "dddd, d MMMM")
                color: root.shade
                font.family: fontSemi.name
                font.pixelSize: face.unit * 0.17
                renderType: Text.NativeRendering
            }
        }
    }
}
