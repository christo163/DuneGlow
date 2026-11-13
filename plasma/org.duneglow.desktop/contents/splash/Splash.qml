// Duneglow splash screen (shown right after login). Plain QtQuick 2.15.
// Plasma sets `stage` (1 to 6) as the session starts; the bar follows it.
import QtQuick 2.15

Rectangle {
    id: root
    color: "#161C2E"

    property int stage: 0
    property bool night: { var h = new Date().getHours(); return h >= 18 || h < 6 }

    property color textCol:  night ? "#E7EBF4" : "#262B33"
    property color mutedCol: night ? "#9AA7C0" : "#5D6672"
    property color cardCol:  night ? Qt.rgba(0.12, 0.16, 0.28, 0.62) : Qt.rgba(1, 1, 1, 0.50)
    property color edgeCol:  night ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.70)
    property color trackCol: night ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0.15, 0.17, 0.2, 0.10)
    property color accentA:  night ? "#E89A62" : "#F2A15A"
    property color accentB:  night ? "#A86BD0" : "#B05CC8"

    readonly property var messages: ["Getting ready", "Loading your desktop", "Starting services",
                                     "Preparing your apps", "Almost ready..", "Welcome"]
    property string message: stage <= 0 ? messages[0] : messages[Math.min(stage, 6) - 1]
    property real progress: Math.max(0.05, Math.min(1, stage / 6))
    Behavior on progress { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

    FontLoader { id: inter;   source: "fonts/Inter-Regular.otf" }
    FontLoader { id: interSB; source: "fonts/Inter-SemiBold.otf" }
    property string uiFont: inter.status === FontLoader.Ready ? inter.name : "sans-serif"
    property string uiBold: interSB.status === FontLoader.Ready ? interSB.name : uiFont

    // Plain background: no wallpaper here, so nothing clashes with the wallpaper you chose.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.night ? "#161C2E" : "#E9E6DD" }
            GradientStop { position: 1.0; color: root.night ? "#262F4E" : "#CBD3E2" }
        }
    }

    Rectangle {
        id: card
        width: 460
        height: 312
        radius: 28
        anchors.centerIn: parent
        color: root.cardCol
        border.color: root.edgeCol
        border.width: 1
        opacity: 0
        scale: 0.96
        NumberAnimation on opacity { to: 1; duration: 450; running: true; easing.type: Easing.OutCubic }
        NumberAnimation on scale   { to: 1; duration: 450; running: true; easing.type: Easing.OutCubic }

        // top sheen
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0;  color: Qt.rgba(1, 1, 1, 0.20) }
                GradientStop { position: 0.45; color: Qt.rgba(1, 1, 1, 0.0) }
            }
        }

        // The cube turns about its vertical axis (48 pre-rendered frames, 180 degrees; opposite faces match, so it loops).
        AnimatedSprite {
            id: logo
            width: 112; height: 112
            anchors.horizontalCenter: parent.horizontalCenter
            y: 30
            source: "images/cube-spin.png"
            frameWidth: 224; frameHeight: 224
            frameCount: 48
            frameRate: 16
            loops: AnimatedSprite.Infinite
            running: true
            smooth: true
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: 24; duration: 1800; easing.type: Easing.InOutSine }
                NumberAnimation { to: 32; duration: 1800; easing.type: Easing.InOutSine }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 176
            text: root.message
            font.family: root.uiBold
            font.pixelSize: 22
            color: root.textCol
        }

        Rectangle {
            id: track
            width: 320; height: 8; radius: 4
            anchors.horizontalCenter: parent.horizontalCenter
            y: 224
            color: root.trackCol
            Rectangle {
                width: Math.max(height, parent.width * root.progress)
                height: parent.height
                radius: height / 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.accentA }
                    GradientStop { position: 1.0; color: root.accentB }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 266
            text: "Duneglow"
            font.family: root.uiFont
            font.pixelSize: 13
            color: root.mutedCol
        }
    }
}
