import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import ts 1.0

Rectangle {
    width: parent.width
    height: parent.height * getPerc()
    x: 0
    y: parent.height - height

    color: "black"
    id: root
    property int sizeX: 3
    property int sizeY: 4
    property int spacing: 1
    property real perc: 0.4
    property var btnData: []

    //property int quickSize: 6
    property var quickData: []
    property real quickPerc: 0.1

    function getPerc() {
        return (perc+quickPerc)
    }
    function btnAt(i) {
        return grid.children[i];
    }

    Grid {
        id: grid
        width: root.width
        height: root.parent.height * perc
        //anchors.horizontalCenter: parent.horizontalCenter
        //anchors.verticalCenter: parent.verticalCenter
        anchors.bottom: root.bottom
        columns: root.sizeX
        rows: root.sizeY
        spacing: root.spacing
        Repeater {
            id: repeater
            model: grid.rows * grid.columns
            ButtonTs {
                height: (grid.height - (grid.rows-1)*grid.spacing) / grid.rows
                width: (grid.width - (grid.columns-1)*grid.spacing) / grid.columns
                text: btnData[index][0]
                /*onPressed*/onClicked: btnData[index][1]()
                font.pointSize: 14
                color: Colors.getBase05()
                txtColor: Colors.getBase00()
            }
        }
    }
    Grid {
        id: quick
        columns: root.quickData.length
        rows: 1
        spacing: root.spacing
        anchors.bottom: grid.top
        width: root.width
        height: root.parent.height * quickPerc
        Repeater {
            model: quick.columns
            Button {
                height: (quick.height - 2*quick.spacing)
                width: (quick.width - (quick.columns-1)*quick.spacing) / quick.columns
                text: root.quickData[index][0]
                onPressed: root.quickData[index][1]()
                font.pointSize: 14
            }
        }
    }
}
