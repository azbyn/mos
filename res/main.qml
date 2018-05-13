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
        onSetOut: { out.text = str; }
        onAppendOut: { out.text += str; }
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

/*
    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page1Form {
        }

        Page2Form {
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            text: qsTr("Page 1")
        }
        TabButton {
            text: qsTr("Page 2")
        }
    }
   */
}
