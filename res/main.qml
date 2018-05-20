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
        if (Qt.platform.os !== "android" || curr.close())
            return;

        close.accepted = false;
    }
    property var editor: Editor {
        onSetOut: {
            console.log("SetOut: '", value, "'");
            out.text = value;
        }
        onAppendOut: {
            console.log("AppendOut: '", value, "'");
            out.text += value;
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
        setType(PageType.Edit);
        //editor.run();
        Qt.inputMethod.hide();

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
