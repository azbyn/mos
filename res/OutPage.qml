import QtQuick 2.0
import QtQuick.Controls 2.2
import ts 1.0

Rectangle {
    id: root
    color: Colors.base00
    x: 0
    y: topRow.height

    width: parent.width
    height: parent.height - y

    property alias text: txt

    Text {
        id: txt
        text: "ja"

        width: parent.width
        height: parent.height
        color: Colors.base05
        font.pointSize: 14
    }
}
