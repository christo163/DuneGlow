// Round pearl-glass button: the same frosted material as the user pill and the password card.
import QtQuick 2.15

Item {
    id: orb
    property Item backdrop: null
    property string iconSource: ""
    property string label: ""
    property string fontFamily: "sans-serif"
    property color labelColor: "#262B33"
    property color tint: Qt.rgba(1, 1, 1, 0.58)        // used when blur is unavailable
    property color frostTint: Qt.rgba(1, 1, 1, 0.30)   // used over the blur
    property color edge: Qt.rgba(1, 1, 1, 0.70)
    signal activated()

    width: 56
    height: 56
    scale: mouse.pressed ? 0.95 : (mouse.containsMouse ? 1.07 : 1.0)
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    GlassPanel {
        anchors.fill: parent
        cornerRadius: width / 2
        backdrop: orb.backdrop
        tint: orb.tint
        frostTint: orb.frostTint
        edge: orb.edge
    }

    Image {
        anchors.centerIn: parent
        width: 24
        height: 24
        source: orb.iconSource
        sourceSize.width: 48
        sourceSize.height: 48
        smooth: true
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: -26
        text: orb.label
        font.family: orb.fontFamily
        font.pixelSize: 13
        color: orb.labelColor
        opacity: mouse.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: orb.activated()
    }
}
