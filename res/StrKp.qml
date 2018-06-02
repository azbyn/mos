import QtQuick 2.0
import QtQuick.Controls 2.2
import ts 1.0

Rectangle {
    id: root
    color: "black"
    property bool isStr: true


    property real perc: 0.1
    property var btnData: [
        ["back", function() {
            strText.reset();
            ep.setCurr(KeypadType.Main);
        }],
        ["<-",   function(){ strText.left(); }],
        ['->',   function(){ strText.right(); }],
        ["undo", function(){ strText.undo(); }],
        ["redo", function(){ strText.redo(); }],
        ["ok",   function() {
            Qt.inputMethod.hide();
            var s = strText.getTextAndReset();
            console.log("ok", s);
            if (s.length === 0) {
                console.log("invalid!");
                return;
            }
            ep.setCurr(KeypadType.Main);


            if (isStr)
                editor.addString(s);
            else
                editor.addIdentifier(s);
        }],
    ]
    property int spacing: 1

    function getPerc() {
        return 0;
    }

    Grid {
        id: grid
        columns: root.btnData.length
        rows: 1
        spacing: root.spacing
        anchors.horizontalCenter: root.horizontalCenter
        anchors.verticalCenter: root.verticalCenter
        width: root.width
        height: root.height - grid.spacing * 4
        Repeater {
            model: grid.columns
            ButtonTs {
                height: root.height - 2 * grid.spacing
                width: (root.width - (grid.columns-1)*grid.spacing)/grid.columns
                text: root.btnData[index][0]
                onClicked/*Pressed*/: root.btnData[index][1]()
                font.pointSize: 14
                color: Colors.Base05
                txtColor: Colors.Base00
            }
        }
    }
}
