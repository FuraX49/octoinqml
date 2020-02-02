import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T

T.Page {
    id: control

    implicitWidth: mainpage.width - 50
    implicitHeight: mainpage.height - 100
    x : 25
    y : 0
    padding: 12
    visible: false
    property bool modal : true
    z: modal ? 1000000 : 0
    property string text
    property alias standardButtons : footer.standardButtons

    signal accepted()
    signal rejected()
    signal reset()


    function open(){
        control.visible = true;
    }

    function showError(errorTitle,errorMessage) {
        control.title = errorTitle;
        text = errorMessage;
        control.visible=true;
    }


    background: Rectangle {
        anchors.fill: parent
        color: "red"
        border.color: control.palette.dark
        border.width: 4
        opacity: 1
    }



    header: Label {
        id : header
        text: control.title
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: control.title
        font.pixelSize:  50
        minimumPixelSize: 10
        fontSizeMode: Text.Fit
        font.bold: true
        background: Rectangle {
            x: 4
            y: 4
            width: parent.width - 8
            height: parent.height -8
            color: "red"
        }
    }

    Text {
        id: element
        text: control.text
        x : 10
        y : header.height
        width: parent.width
        height: parent.height -(header.height+footer.height)
        wrapMode : Text.WordWrap
        maximumLineCount: 50
        styleColor: control.palette.dark
        font.pixelSize:  50
        minimumPixelSize: 10
        fontSizeMode: Text.Fit
        padding: 10
    }

    footer: DialogButtonBox {
        id : footer
        position : DialogButtonBox.Footer
        visible: count > 0
        alignment : Qt.AlignLeft
        background: Rectangle {
            x: 4
            y: 4
            width: parent.width - 8
            height: parent.height -8
            color: "red"
        }

        onAccepted: {
            control.visible=false;
            control.accepted();
        }

        onRejected:  {
            control.visible=false;
            control.rejected();
        }

        onReset: {
            control.reset();
        }


    }

    T.Overlay.modal: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.5)
    }

    T.Overlay.modeless: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.12)
    }
}

