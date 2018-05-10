import QtQuick 2.9
import QtQuick.Controls 2.2
//import "qml"

ApplicationWindow {
    id: app
    visible: true
    width: 404
    height: 720
    title: qsTr("Throwaway Script")
    property int orgHeight

    onClosing: {
        if (Qt.platform.os === "linux") return;
        ep.close()
        close.accepted = false;
    }

    Component.onCompleted: {
        orgHeight = height
        console.log(orgHeight);
    }


    TopRow {
        id: topRow
        width: app.width
        height: orgHeight * perc
        anchors.top: app.top
    }
    EditPage {
        id: ep
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
