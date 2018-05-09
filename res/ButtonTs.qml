import QtQuick 2.0

Rectangle {
    id: button

    property bool checked: false
    property alias text: buttonText.text
    property alias font: buttonText.font
    property alias txtColor: buttonText.color
    Accessible.name: text
    Accessible.description: "This button does " + text
    Accessible.role: Accessible.Button
    Accessible.onPressAction: {
        button.clicked()
    }

    signal clicked

    width: buttonText.width + 20
    height: 30

    Text {
        id: buttonText
        text: parent.description
        anchors.centerIn: parent
        //font.pixelSize: parent.height * .5
        //style: Text.Sunken
        color: "black"
        //styleColor: "black"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: parent.clicked()
    }

    Keys.onSpacePressed: clicked()
}
