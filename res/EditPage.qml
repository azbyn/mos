import QtQuick 2.0
import ts 1.0
import QtQuick.Window 2.2


Item {
    property var curr: mainKp
    property var currType

    Component.onCompleted: {
        setCurr(KeypadType.Main);
    }
    function close() {
        switch (currType) {
        case KeypadType.Main: break;
        case KeypadType.Number: setCurr(KeypadType.Main); break;
        case KeypadType.String: setCurr(KeypadType.Main); break;
        }
    }

    //onCurrChanged: function() {}
    function setCurr(x) {
        currType = x;
        mainKp.visible  = false;
        numKp.visible   = false;
        numText.visible = false;
        strText.visible = false;
        strKp.visible   = false;

        switch (x) {
        case KeypadType.Main:
            curr = mainKp;
            editorText.setActive(true);
            //Qt.inputMethod.hide();
            break;
        case KeypadType.Number:
            editorText.setActive(false);
            curr = numKp;
            numText.visible = true;
            break;
        case KeypadType.String:
            //editorText.setActive(false);
            strText.visible = true;
            curr = strKp;
            //Qt.inputMethod.show();
            //strText.visible = true;
            break;
        default:
            console.log("INVALID CURR: ", x);
            return;
        }
        curr.visible = true;
        editorText.height = height * (1.0 - topRow.perc - curr.getPerc());
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

    StrText {
        id: strText
        x: 5
        y: 5
        height: orgHeight * (0.5 - strKp.perc) - 10
        width: parent.width - 10
    }
    StrKp {
        id: strKp
        visible: false
        width: strText.width
        height: orgHeight * perc
        x: strText.x
        y: strText.y + strText.height
    }
}
