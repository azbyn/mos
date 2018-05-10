import QtQuick 2.0
import ts 1.0

Rectangle {
    function getText() { return txt.text.replace("#", "##").replace("\n", "#n").replace("\t", "#t"); }
    function undo()  { txt.undo(); }
    function redo()  { txt.redo(); }
    function left()  { --txt.cursorPosition; }
    function right() { ++txt.cursorPosition; }
    function reset() { txt.text = ""; txt.cursorPosition = 0; }
    //anchors.fill: parent

    TextEdit {
        id: txt
        x: 2
        y: 2
        //anchors.fill: parent
        height: parent.height - 4
        width: parent.width - 4
        font.pointSize: 16
        color: Colors.getBase05();
        text: "Hello World\n\ta";
        textFormat: TextEdit.PlainText
        wrapMode: TextEdit.Wrap
    }
    onVisibleChanged: {
        if (visible) {
            txt.forceActiveFocus();
            Qt.inputMethod.show();
        } else {
            Qt.inputMethod.hide();
        }
    }
    color: Colors.getBase01();
}
