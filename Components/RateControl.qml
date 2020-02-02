import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

PaneBase  {
    id: control
    padding: 3
    spacing: 3
    implicitHeight: 50
    implicitWidth: 150

    property string title: "Rate"
    property real maxRate : 300
    property real minRate: 0
    property real currentRate: 100
    property real stepsize : 5

    signal ratechanged (real  factor)


    GridLayout {
        id: gridLayout
        rows: 1
        anchors.margins: 2
        columnSpacing: 0
        rowSpacing: 0
        columns: 5
        anchors.fill: parent
        Slider {
            id: slider
            padding: 0
            Layout.fillWidth: true
            Layout.columnSpan: 3
            Layout.fillHeight: true
            implicitWidth: Math.floor(parent.width * 0.6)
            Layout.margins: 0
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            snapMode: Slider.SnapOnRelease
            orientation: Qt.Horizontal
            value: control.currentRate
            from : control.minRate
            to   : control.maxRate
            stepSize : control.stepsize
            background: Text {
                id: name
                text: slider.value.toString()
                verticalAlignment: Text.AlignTop
                font.pixelSize: ScreenParams.rc_FontSmall
                width : parent.width
                height: parent.height
            }
        }

        Button {
            id: toolButton
            implicitWidth: Math.floor(parent.width * 0.4)
            text: control.title
            Layout.rowSpan: 1
            Layout.columnSpan: 2
            display: AbstractButton.TextOnly
            font.pixelSize: ScreenParams.rc_FontSmall
            rightPadding: 0
            Layout.fillWidth: true
            highlighted: false
            autoRepeat: false
            spacing: 0
            padding: 0
            leftPadding: 0
            Layout.fillHeight: true
            Layout.margins: 0
            onClicked: {
                ratechanged(slider.value);
            }
        }
    }
}
