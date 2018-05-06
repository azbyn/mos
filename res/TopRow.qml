import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle {
    id: root
    color: "black"

    property real perc: 0.075
    property var btnData: [
        ["edit", function(){} ],
        ['in',   function(){} ],
        ["out",  function(){} ],
        ["view", function(){} ],
        ["run",  function(){} ],
        ["ops",  function(){} ],
    ]
    property int spacing: 1

    Grid {
        id: grid
        columns: root.btnData.length
        rows: 1
        spacing: root.spacing
        anchors.horizontalCenter: root.horizontalCenter
        anchors.verticalCenter: root.verticalCenter
        width: root.width
        height: root.height
        Repeater {
            model: grid.columns
            Button {
                height: root.height - 2 * grid.spacing
                width: (root.width - (grid.columns-1)*grid.spacing)/grid.columns
                text: root.btnData[index][0]
                onPressed: root.btnData[index][1]()
                font.pointSize: 14
            }
        }
    }
}
