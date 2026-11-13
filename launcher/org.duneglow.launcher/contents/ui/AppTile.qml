/* Duneglow Launcher: one app icon with label. GPL-3.0-or-later. UNTESTED (no Qt runtime for the author). */
import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: tile
    property alias icon: ico.source
    property alias label: txt.text
    property string fontFamily: ""
    property bool light: false
    signal clicked()

    width: 112
    height: 112

    Rectangle {                       // pearl glass hover plate
        anchors.fill: parent
        anchors.margins: 2
        radius: 18
        color: tile.light ? Qt.rgba(1, 1, 1, ma.pressed ? 0.62 : 0.45) : Qt.rgba(1, 1, 1, ma.pressed ? 0.20 : 0.12)
        border.width: 1
        border.color: tile.light ? Qt.rgba(0.20, 0.25, 0.35, 0.20) : Qt.rgba(1, 1, 1, 0.22)
        opacity: ma.containsMouse || tile.activeFocus ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }
    Kirigami.Icon {
        id: ico
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 12
        width: 56
        height: 56
    }
    Text {
        id: txt
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.top: ico.bottom
        anchors.topMargin: 8
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        maximumLineCount: 2
        wrapMode: Text.Wrap
        color: tile.light ? "#262B33" : "white"
        font.pixelSize: 13
        style: tile.light ? Text.Normal : Text.Raised
        styleColor: Qt.rgba(0, 0, 0, 0.45)
        font.family: tile.fontFamily
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.clicked()
    }
    Keys.onReturnPressed: tile.clicked()
    Keys.onEnterPressed: tile.clicked()
}
