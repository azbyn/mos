import QtQuick 2.0
import QtQuick.Controls 2.2
import ts 1.0

Rectangle {
    id: root
    color: "black"

    property real perc: 0.075
    property var btnData: [
        ["edit", function(){ app.setType(PageType.Edit); }],
        ['in',   function(){ app.setType(PageType.In); }],
        ["out",  function(){ app.setType(PageType.Out); }],
        ["view", function(){ app.setType(PageType.View); }],
        ["run",  function(){
            editor.run();
            app.setType(PageType.Out);
        }],
        ["ops",  function(){ app.setType(PageType.Options); }],
    ]
    property int spacing: 1
    property int _old: 0
    function setBtn(x) {
        grid.children[_old].color = Colors.base05;
        grid.children[_old].txtColor = Colors.base00;
        grid.children[_old].font.bold = false;

        grid.children[x].color = Colors.base06;
        grid.children[x].txtColor = Colors.base0D;
        grid.children[x].font.bold = true;

        _old = x;
    }

    Grid {
        id: grid
        columns: root.btnData.length
        rows: 1
        spacing: root.spacing
        anchors.horizontalCenter: root.horizontalCenter
        anchors.verticalCenter: root.verticalCenter
        width: root.width
        height: root.height - grid.spacing
        Repeater {
            model: grid.columns
            ButtonTs {
                height: root.height - 2 * grid.spacing
                width: (root.width - (grid.columns-1)*grid.spacing)/grid.columns
                text: root.btnData[index][0]
                onClicked: root.btnData[index][1]()
                font.pointSize: 14
            }
        }
    }
}
