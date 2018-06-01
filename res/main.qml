import QtQuick 2.9
import QtQuick.Controls 2.2
import ts 1.0

ApplicationWindow {
    id: app
    visible: true
    width: 404
    height: 720
    title: qsTr("Throwaway Script")
    //property int orgHeight

    property var type: PageType.Edit

    onClosing: {
        var curr;
        switch(type) {
        case PageType.Edit: curr = ep; break;
        case PageType.Out: curr = out; break;

        }
        if (Qt.platform.os !== "android")// || curr.close())
            return;
        curr.close();
        close.accepted = false;
    }
    property var editor: Editor {
        function addParenPair() {
            add_lParen();
            var c = getCursor();
            add_rParen();
            setCursorUnsafe(c);
        }
        function addCurlyPair() {
            add_lCurly();
            var c = getCursor();
            add_rCurly();
            setCursorUnsafe(c);
        }
        function addSquarePair() {
            add_lSquare();
            var c = getCursor();
            add_rSquare();
            setCursorUnsafe(c);
        }
        function addBody() {
            var c = getCursor();
            add_lCurly();
            add_newLine();
            add_rCurly();
            setCursorUnsafe(c);
        }
    }

    function setType(x) {
        type = x;
        ep.visible = false;
        out.visible = false;

        switch(type) {
        case PageType.Edit: ep.visible = true; break;
        case PageType.Out:  out.visible = true; break;
        }
        topRow.setBtn(x);
    }

    Component.onCompleted: {
        /*function Timer() {
            return Qt.createQmlObject("import QtQuick 2.0; Timer {}", app);
        }*/
        setType(PageType.Edit);
        if (1) {
            /*var timer = new Timer();
            timer.interval = 1000;
            timer.repeat = false;
            timer.triggered.connect(function() {*/
            editor.run();
            setType(PageType.Out);
            /*});
            timer.start();*/
        }

        //Qt.inputMethod.hide();

        //orgHeight = height
    }

    TopRow {
        id: topRow
        width: app.width
        height: app.height * perc
        anchors.top: app.top
    }
    EditPage {
        id: ep
    }
    OutPage {
        id: out
    }
}
