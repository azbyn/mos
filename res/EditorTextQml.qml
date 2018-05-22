import QtQuick 2.0
import QtQuick.Controls 1.4
import ts 1.0

Rectangle {
    id: root
    color: Colors.base00

    function setActive(val) {
        sv.et.setActive(val);
    }

    ScrollView {
        id: sv
        anchors.fill: parent
        //anchors.margins: 4
        flickableItem.flickableDirection: Flickable.AutoFlickIfNeeded
        property alias et: editorText

        EditorText {
            minWidth: root.width
            minHeight: root.height

            id: editorText
            width: root.width
            height: root.height
        }
   }
}
