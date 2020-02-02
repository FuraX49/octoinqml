import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T
import QtQuick.Layouts 1.3


PaneBase {
    id: control
    implicitWidth: 80
    implicitHeight: 160
    spacing: 10
    property string title: objectName
    property int temp1: 180
    property int temp2: 210
    property int actualTemp: 0
    property int targetTemp: 0

    signal preheatChange(int  temperature)

    property bool _humanTouch : false

    function updateTemps(actual,target){
        if ((target!==targetTemp) || (actual !==actualTemp)) {
            if (target===0)  {
                targetTemp=target;
                btnOnOff.checked=true;
            } else {

                actualTemp=actual;
                targetTemp=target;
                if (actualTemp>(temp1+10)) {
                    btntemp2.checked=true;
                } else {
                    btntemp1.checked=true;
                }
            }
        }
    }

    ButtonGroup {
        buttons: colbutton.children
    }

    ColumnLayout {
        id : colbutton
        spacing: 6
        Layout.margins: 6
        anchors.fill: parent

        Label {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            text : title
            font.pixelSize: ScreenParams.rc_FontBig
            Layout.fillHeight: true
            Layout.fillWidth: true
        }


        RoundButton {
            id: btntemp2
            text: btnOnOff.checked?cfg_TempName2:targetTemp.toString();
            font.pixelSize: ScreenParams.rc_FontTitle
            checked: false
            checkable: true
            radius: height / 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            implicitHeight : 24
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onClicked: {
                preheatChange(temp2);
            }
        }

        RoundButton {
            id: btntemp1
            text: btnOnOff.checked?cfg_TempName1:actualTemp.toString();
            font.pixelSize: ScreenParams.rc_FontTitle
            checked: false
            checkable: true
            radius: height / 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            implicitHeight : 24
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onClicked: {
                preheatChange(temp1);
            }
        }

        RoundButton {
            id: btnOnOff
            text: qsTr("OFF")
            font.pixelSize: ScreenParams.rc_FontTitle
            font.bold: true
            checked: true
            checkable: true
            radius: height / 4
            Layout.fillHeight: true
            implicitHeight : 24
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onClicked: {
                preheatChange(0);
            }
        }


    }
    /*

    property int maxTemp : 300
    property int minTemp: 0


    background: Rectangle {
            id : rectControl
            radius: 4
            color: control.palette.window
            border.width: borderWidth
            border.color: control.palette.buttonText

            gradient: Gradient {
                GradientStop { position: 0.0; color: btnOnOff.checked? "red" : control.palette.window }
                GradientStop { position: control.targetTemp/control.maxTemp; color:  btnOnOff.checked? "yellow" : control.palette.window }
                GradientStop { position: 1.0; color: btnOnOff.checked?"blue" : control.palette.window  }
            }

            Rectangle {
                id : markTarget
                color : control.palette.window
                width : parent.width - borderWidth*2
                x :borderWidth
                height :5
                border.width: 1
                border.color: control.palette.buttonText
                y : control.contentHeight- ((control.contentHeight/control.maxTemp) * control.targetTemp );
            }

            Rectangle {
                id : markCurrent
                color : control.palette.buttonText
                x :borderWidth
                width : parent.width - borderWidth*2
                height :3
                y : control.contentHeight- ((control.contentHeight/control.maxTemp) * control.currentTemp );
            }
        }
        */

}
