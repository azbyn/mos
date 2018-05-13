import QtQuick 2.0
import QtQuick.Controls 1.4
import ts 1.0

Rectangle {
    width: parent.width
    height: parent.height * getPerc()
    x: 0
    y: parent.height - height

    color: "black"
    id: root

    property var type: LibType.Main
    readonly property int spacing: 1
    readonly property real perc: 0.2
    readonly property real quickPerc: 0.1

    readonly property real elementPerc: 0.1
    readonly property var elementData: [
        ["IO",        function() { setType(LibType.IO); }],
        ["Math",      function() { setType(LibType.Math); }],
        ["Misc",      function() { setType(LibType.Misc); }],
    ]
    readonly property var quickData: [
        ["back", function(){ ep.setCurr(KeypadType.Main); } ],
        ["<-", function(){}],
        ["->", function(){}],
    ]

    function getPerc() { return perc + quickPerc; }
    function setType(x) {
        type = x;
        switch (type) {
        case LibType.Main: break;
        case LibType.IO: break;
        case LibType.Math: break;
        case LibType.Misc: break;
        }
    }

    ScrollView {
        id: sv

        anchors.fill: parent
        width: root.width
        height: app.height * perc
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        flickableItem.flickableDirection: Flickable.VerticalFlick
        Grid {
            id: grid
            rows: elementData.length
            columns: 1
            spacing: root.spacing
            width: root.width
            height: app.height * elementPerc * rows

            Repeater {
                model: grid.rows
                ButtonTs {
                    height: (grid.height - (grid.rows-1)*grid.spacing) / grid.rows
                    width: grid.width - (grid.columns-1)*grid.spacing
                    //color: "blue"
                    text: elementData[index][0]
                    onClicked: elementData[index][1]()
                    font.pointSize: 14
                }
            }
        }
    }
    Grid {
        id: quick
        columns: root.quickData.length
        rows: 1
        spacing: root.spacing
        anchors.bottom: sv.top
        width: root.width
        height: root.parent.height * quickPerc
        Repeater {
            model: quick.columns
            ButtonTs {
                height: (quick.height - 2*quick.spacing)
                width: (quick.width - (quick.columns-1)*quick.spacing) / quick.columns
                text: root.quickData[index][0]
                onClicked: root.quickData[index][1]()
                font.pointSize: 14
            }
        }
    }
}
