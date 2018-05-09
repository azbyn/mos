import QtQuick 2.0
import ts 1.0

Item {
    property var curr: mainKp

    Component.onCompleted: {
        setCurr(KeypadType.Main);
    }

    //onCurrChanged: function() {}
    function setCurr(x) {
        numKp.visible   = false;
        mainKp.visible  = false;
        numText.visible = false;

        switch (x) {
        case KeypadType.Main:
            curr = mainKp;
            editorText.setActive(true);
            break;
        case KeypadType.Number:
            editorText.setActive(false);
            curr = numKp;
            numText.visible = true;
            break;
        default:
            console.log("INVALID CURR: ", x);
            return;
        }
        curr.visible = true
        editorText.height = height * (1.0 - topRow.perc - curr.getPerc())
    }

    width: parent.width
    height: parent.height
    MainKp {
        id: mainKp
        visible: false
    }
    NumKp {
        id: numKp
        visible: false
    }


    EditorText {
        id: editorText
        width: parent.width
        //height: root.height* (1 - (topRow.perc + getCurrent().getPerc()))
        x: 0
        y: topRow.height
        //anchors.top: topRow.bottom
        //anchors.bottom: curr.top
   }
   NumberText {
        id: numText
        x: 0
        y: topRow.height
        //anchors.bottom: mainKp.top
        height: parent.height * (1.0 - topRow.perc - numKp.getPerc())
        width: parent.width
        visible: false
        onInvalidate: numKp.invalidate()
        onValidate: numKp.validate()
    }
}
