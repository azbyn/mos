import QtQuick 2.0
import QtQuick.Controls 1.4
import mos 1.0

Rectangle {
    id: root
    color: Colors.Base00

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
