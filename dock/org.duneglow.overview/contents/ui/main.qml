/*
 * Duneglow Overview button. GPL-3.0-or-later.
 * Click = KWin Overview (same as the Meta+W shortcut), via the kglobalaccel D-Bus call (gdbus).
 * Written without a Qt runtime available to the author: UNTESTED.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    toolTipMainText: "Overview"
    toolTipSubText: "Show all windows"

    P5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => disconnectSource(source)
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.iconSizes.medium
        Layout.minimumHeight: Kirigami.Units.iconSizes.medium

        Kirigami.Icon {
            anchors.fill: parent
            anchors.margins: 4
            source: "view-grid"
            active: mouse.containsMouse
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: runner.connectSource("gdbus call --session --dest org.kde.kglobalaccel --object-path /component/kwin --method org.kde.kglobalaccel.Component.invokeShortcut Overview")
        }
    }
}
