import QtQuick 2.15

Item {
    id: panel
    property Item backdrop: null
    property real cornerRadius: 22
    property color tint: Qt.rgba(1, 1, 1, 0.58)        // used when blur is unavailable
    property color frostTint: Qt.rgba(1, 1, 1, 0.30)   // used over the blur
    property color edge: Qt.rgba(1, 1, 1, 0.70)
    property bool frosted: frostLoader.status === Loader.Ready
    default property alias content: inner.data

    // soft shadow
    Rectangle { anchors.fill: parent; anchors.margins: -9; radius: panel.cornerRadius + 9; color: Qt.rgba(0, 0, 0, 0.025) }
    Rectangle { anchors.fill: parent; anchors.margins: -4; radius: panel.cornerRadius + 4; color: Qt.rgba(0, 0, 0, 0.04) }

    Loader {
        id: frostLoader
        anchors.fill: parent
        source: panel.backdrop ? "Frost.qml" : ""
        onLoaded: {
            item.backdrop = panel.backdrop
            item.host = panel
            item.cornerRadius = panel.cornerRadius
        }
    }

    // tint and border
    Rectangle {
        anchors.fill: parent
        radius: panel.cornerRadius
        color: panel.frosted ? panel.frostTint : panel.tint
        border.color: panel.edge
        border.width: 1
    }
    // top sheen, gives the glass its edge light
    Rectangle {
        anchors.fill: parent
        radius: panel.cornerRadius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.22) }
            GradientStop { position: 0.45; color: Qt.rgba(1, 1, 1, 0.0) }
        }
    }

    Item { id: inner; anchors.fill: parent }
}
