import QtQuick 2.0
import QtQuick.Controls 1.4
import ts 1.0

Rectangle {
    id: root
    color: Colors.base00
    x: 0
    y: topRow.height

    width: parent.width
    height: parent.height - y

    ScrollView {
        id: sv
        anchors.fill: parent
        width: root.width
        height: root.height
        //anchors.margins: 4
        flickableItem.flickableDirection: Flickable.AutoFlickIfNeeded
        OutText {
            id: outText
            width: root.width
            height: root.height
        }

        /*
        Text {
            id: txt
            text: ""
            width: root.width
            height: root.height
            color: Colors.base05
            font.family: editor.getFontFamMono()
            font.pointSize: 14
            onTextChanged: {
                width = contentWidth
                height = contentHeight
            }
        }*/
    }
}
