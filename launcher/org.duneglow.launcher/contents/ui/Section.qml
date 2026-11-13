/* Duneglow Launcher: a titled block of app tiles from one Kicker model. GPL-3.0-or-later. UNTESTED. */
import QtQuick

Column {
    id: sec
    property var srcModel: null
    property string title: ""
    property string fontFamily: ""
    property bool light: false
    property int cellWidth: 112
    signal launched()

    visible: rep.count > 0
    spacing: 10

    Text {
        text: sec.title
        color: sec.light ? Qt.rgba(0.15, 0.17, 0.20, 0.75) : Qt.rgba(1, 1, 1, 0.9)
        style: sec.light ? Text.Normal : Text.Raised
        styleColor: Qt.rgba(0, 0, 0, 0.45)
        font.pixelSize: 13
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 1.2
        font.family: sec.fontFamily
        leftPadding: 4
    }
    Flow {
        width: sec.width
        Repeater {
            id: rep
            model: sec.srcModel
            delegate: AppTile {
                required property int index
                required property var model
                icon: model.decoration
                label: model.display
                fontFamily: sec.fontFamily
                light: sec.light
                onClicked: {
                    sec.srcModel.trigger(index, "", null)
                    sec.launched()
                }
            }
        }
    }
}
