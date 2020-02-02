import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import "../Components"


PageTemplate {
    id: anotherpage
    title: qsTr("Components")
    implicitWidth: 800
    implicitHeight: 480
    icon.source: "../Images/toolbox.svg"

    GridLayout {
        id: grid
        columnSpacing: ScreenParams.rc_ItemSpace
        rowSpacing: ScreenParams.rc_ItemSpace

        rows: ScreenParams.isPortrait?8:4
        columns: ScreenParams.isPortrait?1:2
        anchors.fill: parent
        Layout.margins: ScreenParams.rc_ItemSpace

        RateControl{
            id: rcFeed
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: false
            Layout.fillWidth: false
            title : "Feed\nRate"
            minRate: 50
            maxRate: 150

        }

        RateControl{
            id: rcFlow
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: false
            Layout.fillWidth: false
            title : "Flow\nRate"
            minRate: 75
            maxRate: 125
        }

        FanControl {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: false
            Layout.fillWidth: false

        }

        StepBox {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: false
            Layout.fillWidth: false

        }
    }


}
