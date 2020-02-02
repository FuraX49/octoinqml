import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T
import QtQuick.Layouts 1.3

import "OctoPrintShared.js" as OPS


T.Page {
    id: control

    implicitWidth: mainpage.width - 20
    implicitHeight: mainpage.height - 100
    x : 10
    y : 0
    padding: 10
    visible: false
    property bool modal : true
    z: modal ? 1000000 : 0
    property string text
    property alias standardButtons : footer.standardButtons

    signal accepted()

    title: "File Info"

    property var  opsjob : null

    function open(){
        control.visible = true;
    }

    function showInfo() {
        opsjob=OPS.job;
        lbfilament.text="";
        for ( var f in opsjob.filament ) {
           lbfilament.text += f +  ":" +  (opsjob.filament[f].length/1000).toPrecision(2)  + "m\t"
        }
        open();
    }


    background: Rectangle {
        anchors.fill: parent
        color: control.palette.window
        border.color: control.palette.buttonText
        border.width: 4
        opacity: 1
    }


    header: Label {
        id : header
        text: control.title
        color: control.palette.buttonText
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
            color: control.palette.window
        }
    }

    GridLayout {
        id: grid
        x : 10
        y : header.height
        width: parent.width
        height: parent.height -(header.height+footer.height)


        anchors.bottomMargin: ScreenParams.rc_ItemHeight
        columnSpacing: ScreenParams.rc_ItemSpace
        rowSpacing: ScreenParams.rc_ItemSpace

        rows: 5
        columns: 2
        anchors.fill: parent


        Label {
            id : lbfile
            text: "File :"
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id: txt_url
            text:  (opsjob!==null) ? opsjob.file.origin +"/"+ opsjob.file.path : ""
            horizontalAlignment: Text.AlignLeft
            color: control.palette.buttonText
            font.bold: true
            Layout.fillHeight: false
            Layout.fillWidth: true
        }

        Label {
            text: "Date :"
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true

        }
        Label {
            text: (opsjob!==null)? new Date(opsjob.file.date*1000).toLocaleString(locale,"yyyy/MM/dd HH:mm:ss") :""
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignLeft
            font.bold: true
            Layout.fillHeight: false
            Layout.fillWidth: true
        }

        Label {
            text: "Size :"
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Label {
            text: (opsjob!==null)?  Math.round(opsjob.file.size/1024) + "Kb" : ""
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignLeft
            font.bold: true
            Layout.fillHeight: false
            Layout.fillWidth: true
        }


        Label {
            text: "Estimated print time :"
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Label {
            text: (opsjob!==null)?  OPS.formatMachineTimeString(opsjob.estimatedPrintTime) : ""
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignLeft
            font.bold: true
            Layout.fillHeight: false
            Layout.fillWidth: true
        }

        Label {
            text: "Time of the last print :"
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Label {
            text: (opsjob!==null)?  OPS.formatMachineTimeString(opsjob.lastPrintTime):""
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignLeft
            font.bold: true
            Layout.fillHeight: false
            Layout.fillWidth: true
        }

        Label {
            text: "filaments :"
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Label {
            id : lbfilament
            text: "";
            color: control.palette.buttonText
            horizontalAlignment: Text.AlignLeft
            font.bold: true
            Layout.fillHeight: false
            Layout.fillWidth: true
        }
    }


    footer: DialogButtonBox {
        id : footer
        position : DialogButtonBox.Footer
        visible: count > 0
        standardButtons: Dialog.Ok
        background: Rectangle {
            x: 4
            y: 4
            width: parent.width - 8
            height: parent.height -8
            color: control.palette.window
        }

        onAccepted: {
            control.visible=false;
            control.accepted();
        }
    }

    T.Overlay.modal: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.5)
    }

    T.Overlay.modeless: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.12)
    }


}
