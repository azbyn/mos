import QtQuick 2.9
import QtQuick.Controls 2.2
//import "qml"

ApplicationWindow {
    id: root
    visible: true
    width: 404
    height: 720
    title: qsTr("Throwaway Script")



    TopRow {
        id: topRow
        width: root.width
        height: root.height * perc
        anchors.top: root.top
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
