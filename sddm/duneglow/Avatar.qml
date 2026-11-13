import QtQuick 2.15
import QtQuick.Effects

Rectangle {
    id: av
    property int size: 76
    property string letter: "?"
    property string imageSource: ""
    property color colA: "#F2A15A"
    property color colB: "#B05CC8"
    property string fontFamily: "sans-serif"
    width: size; height: size; radius: size / 2
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: av.colA }
        GradientStop { position: 1.0; color: av.colB }
    }
    Text {
        anchors.centerIn: parent
        visible: img.status !== Image.Ready
        text: av.letter
        font.family: av.fontFamily
        font.pixelSize: av.size * 0.42
        color: "#FFFFFF"
    }
    // The photo is cut to a circle with a mask (a plain Image would stay square on top of the round background).
    Image {
        id: img
        anchors.fill: parent
        source: av.imageSource
        fillMode: Image.PreserveAspectCrop
        visible: false
        layer.enabled: true
        smooth: true
        sourceSize.width: av.size * 2
        sourceSize.height: av.size * 2
    }
    Item {
        id: circleMask
        anchors.fill: parent
        visible: false
        layer.enabled: true
        Rectangle { anchors.fill: parent; radius: width / 2; color: "white" }
    }
    MultiEffect {
        anchors.fill: parent
        visible: img.status === Image.Ready
        source: img
        autoPaddingEnabled: false
        maskEnabled: true
        maskSource: circleMask
    }
}
