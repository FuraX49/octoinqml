import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

PaneBase {
    id: control
    padding: 0
    spacing: 0

    implicitHeight: 50
    implicitWidth: 200
    property string title: "Fan\n0"
    property real maxSpeed : 100
    property real minSpeed: 0
    property real currentSpeed: 100
    property real stepsize : 5

    signal changedspeedfan (int fan,bool onoff,real  speed)

    property var speedfan  : [100,100,100,100,100]
    property var offan  : [false,false,false,false,false]
    property int fanindex  : 0

    function majNbFans(nb) {
        while (speedfan.length> nb) {speedfan.pop();}
        while (speedfan.length< nb) {speedfan.push(100);}
        speedfan.length=nb;
    }

    GridLayout {
        id: row
        rowSpacing: 1
        columnSpacing: 2
        anchors.fill: parent
        Slider {
            id: slider
            clip: false
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width * 0.6
            Layout.margins: 2
            snapMode: Slider.SnapOnRelease
            orientation: Qt.Horizontal
            value: control.currentSpeed
            from : control.minSpeed
            to   : control.maxSpeed
            stepSize : control.stepsize
            background: Text {
                id: name
                text: slider.value.toString()
                font.weight: Font.Light
                font.pixelSize: ScreenParams.rc_FontSmall
                width : parent.width
                height: parent.height
            }
            onValueChanged: {
                speedfan[fanindex]=value;
                if (offan[fanindex]) {
                    changedspeedfan(fanindex,true,speedfan[fanindex]);
                }
            }
        }

        Button {
            id: precFan
            Layout.margins: 2
            Layout.rightMargin: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: Math.floor(parent.width * 0.1)
            text: "-"
            font.bold: true
            font.pixelSize: ScreenParams.rc_FontNormal
            enabled: (fanindex>0)
            onClicked: {
                if (fanindex>0) {
                    fanindex--;
                    toolButton.text="Fan\n"+fanindex.toString();
                    slider.value=speedfan[fanindex];
                    toolButton.checked= offan[fanindex];
                }
            }
        }

        Button {
            id: toolButton
            text: control.title
            spacing: 0
            padding: 0
            topPadding: ScreenParams.rc_FontSmall /2
            checkable: true
            checked: false
            font.pixelSize: ScreenParams.rc_FontSmall
            Layout.margins: 2
            Layout.leftMargin: 0
            Layout.rightMargin: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: Math.floor(parent.width * 0.2)
            onClicked: {
                offan[fanindex]=checked;
                changedspeedfan(fanindex,checked,speedfan[fanindex]);
            }
        }

        Button {
            id: nextFan
            Layout.leftMargin: 0
            Layout.margins: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: Math.floor(parent.width * 0.1)
            text: "+"
            font.bold: true
            font.pixelSize: ScreenParams.rc_FontNormal
            enabled: (fanindex<speedfan.length-1)
            onClicked: {
                if (fanindex<speedfan.length-1) {
                    fanindex++;
                    toolButton.text="Fan\n"+fanindex.toString();
                    slider.value=speedfan[fanindex];
                    toolButton.checked= offan[fanindex];
                }
            }

        }


    }
}
