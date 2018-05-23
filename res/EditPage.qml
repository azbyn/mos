import QtQuick 2.0
import QtQuick.Controls 1.4
//import QtQuick.Window 2.2
import ts 1.0

Item {
    id: root
    property var curr: mainKp
    property var currType

    width: parent.width
    height: parent.height

    Component.onCompleted: {
        setCurr(KeypadType.Operators/*Main*/);
    }
    function close() {
        switch (currType) {
        case KeypadType.Main: return true;

        }
        setCurr(KeypadType.Main);
        return false;
    }

    //onCurrChanged: function() {}
    function setCurr(x) {
        currType = x;
        mainKp.visible  = false;
        numKp.visible   = false;
        numText.visible = false;
        strText.visible = false;
        strKp.visible   = false;
        libKp.visible   = false;
        varKp.visible   = false;
        stmtKp.visible  = false;
        opKp.visible    = false;

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
        case KeypadType.Vars:
            //editorText.setActive(false);
            strText.visible = true;
            curr = varKp;
            //Qt.inputMethod.show();
            //strText.visible = true;
            break;
        case KeypadType.Libs:
            curr = libKp;
            break;
        case KeypadType.Statements:
            curr = stmtKp;
            break;
        case KeypadType.Operators:
            curr = opKp;
            break;
        default:
            console.log("INVALID CURR: ", x);
            return;
        }
        curr.visible = true;
        editorText.height = height * (1.0 - topRow.perc - curr.getPerc());
    }

    OperatorsKpQml {
        id: opKp
    }
    MainKp {
        id: mainKp
    }
    NumKp {
        id: numKp
    }

    EditorTextQml {
        id: editorText
        width: parent.width
        x: 0
        y: topRow.height
    }

    NumberText {
        id: numText
        x: 0
        y: topRow.height
        //anchors.bottom: mainKp.top
        height: root.height * (1.0 - topRow.perc - numKp.getPerc())
        width: root.width
        onInvalidate: numKp.invalidate()
        onValidate: numKp.validate()
    }

    StrText {
        id: strText
        x: 5
        y: 5
        height: root.height * (0.5 - strKp.perc) - 10
        width: root.width - 10
    }
    StrKp {
        id: strKp
        width: strText.width
        height: root.height * perc
        x: strText.x
        y: strText.y + strText.height
    }
    StrKp {
        id: varKp
        width: strText.width
        height: root.height * perc
        x: strText.x
        y: strText.y + strText.height
        isStr: false
    }

    LibKp {
        id: libKp
    }
    StmtKp {
        id: stmtKp
    }
}
