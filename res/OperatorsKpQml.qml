import QtQuick 2.0
import ts 1.0

Rectangle {
    color: Colors.Base00
    width: parent.width
    height: parent.height * perc
    x: 0
    y: parent.height - height
    property real perc: 0.5
    OperatorsKp {
        id: opKp
        anchors.fill: parent
        onGotoMain: ep.setCurr(KeypadType.Main);
    }
    function back() {
        opKp.back();
    }

    function getPerc() {
        return perc;
    }
}
