import QtQuick 2.0
import QtQuick.Controls 1.4
import ts 1.0

Rectangle {
    function getTextAndReset() {
        Qt.inputMethod.hide();
        var v = txt.text.replace("#", "##").replace("\n", "#n").replace("\t", "#t");
        reset();
        console.log("getText", v);
        return v;
    }
    function undo()  { txt.undo(); }
    function redo()  { txt.redo(); }
    function left()  { --txt.cursorPosition; }
    function right() { ++txt.cursorPosition; }
    function reset() { txt.text = ""; txt.cursorPosition = 0; }
    //anchors.fill: parent
    ScrollView {
        anchors.fill: parent
        anchors.margins: 4
        flickableItem.flickableDirection: Flickable.AutoFlickIfNeeded
        //ScrollBar.horizontal.interactive: true
        TextEdit {
            id: txt
            //x: 2
            //y: 2
            //anchors.fill: parent
            //height: parent.height - 4
            //width: parent.width - 4
            font.pointSize: 16
            color: Colors.Base05
            text: "";
            textFormat: TextEdit.PlainText
            wrapMode: TextEdit.Wrap
        }
    }
    onVisibleChanged: {
        if (visible) {
            txt.forceActiveFocus();
            Qt.inputMethod.show();
        } else {
            Qt.inputMethod.hide();
        }
    }
    Component.onCompleted: {
        Qt.inputMethod.hide();
    }

    color: Colors.Base01
}
