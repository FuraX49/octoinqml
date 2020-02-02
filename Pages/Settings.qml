import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.11

import "../Components"


PageTemplate {
    id: settingspage
    title: qsTr("Settings")
    icon.source: "../Images/settings.svg"

    property alias btn_cnx: btn_cnx
    implicitWidth: 800
    implicitHeight: 480


    GridLayout {
        id: grid
        columnSpacing: ScreenParams.rc_ItemSpace
        rowSpacing: ScreenParams.rc_ItemSpace

        rows: ScreenParams.isPortrait?14:7
        columns: ScreenParams.isPortrait?1:2
        anchors.fill: parent
        Layout.margins: ScreenParams.rc_ItemSpace

        Label {
            id: label
            text: qsTr("Toggle In QML")
            font.italic: true
            font.bold: true
            font.pixelSize: ScreenParams.rc_FontTitle
            horizontalAlignment: Text.AlignHCenter
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.columnSpan: ScreenParams.isPortrait?1:2
        }


        Label {
            id : lbUrl
            width: 100
            text: qsTr("Url :")
            font.italic: true
            font.pixelSize: ScreenParams.rc_FontTitle
            horizontalAlignment: ScreenParams.isPortrait? Text.AlignLeft:Text.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        TextEdit {
            id: txt_url
            text: cfg_Url
            topPadding: -1
            horizontalAlignment: Text.AlignLeft
            font.bold: true
            font.pixelSize: ScreenParams.rc_FontTitle
            color: ScreenParams.colorText

            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id : lbapiKey
            width: 100
            text: qsTr("ApiKey :")
            font.italic: true
            font.pixelSize: ScreenParams.rc_FontTitle
            horizontalAlignment: ScreenParams.isPortrait? Text.AlignLeft:Text.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        TextEdit {
            id: txt_api_key
            text:cfg_Api_Key.toString()
            font.bold: true
            font.pixelSize: ScreenParams.rc_FontTitle
            color: ScreenParams.colorText

            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id : lusername
            width: 100
            text: qsTr("User Name :")
            font.italic: true
            font.pixelSize: ScreenParams.rc_FontTitle
            horizontalAlignment:ScreenParams.isPortrait? Text.AlignLeft:Text.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        TextEdit {
            id: txt_username
            text:cfg_UserName.toString()
            font.pixelSize: ScreenParams.rc_FontTitle
            font.bold: true
            color: ScreenParams.colorText

            Layout.fillHeight: true
            Layout.fillWidth: true
        }



        Label {
            id : lb_ports
            width: 100
            text: qsTr("Printer Port :")
            font.italic: true
            font.pixelSize: ScreenParams.rc_FontTitle
            horizontalAlignment: ScreenParams.isPortrait? Text.AlignLeft:Text.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
        }


        TextEdit {
            id: txt_port
            text: cfg_printerPort
            font.pixelSize: ScreenParams.rc_FontTitle
            font.bold: true
            color: ScreenParams.colorText

            Layout.fillHeight: true
            Layout.fillWidth: true
        }



        Label {
            id : lb_profils
            width: 100
            text: qsTr("Profile Identifier : ")
            font.pixelSize: ScreenParams.rc_FontTitle
            font.italic: true
            horizontalAlignment: ScreenParams.isPortrait? Text.AlignLeft:Text.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        TextEdit {
            id: txt_profil
            text: cfg_printerProfile
            font.pixelSize: ScreenParams.rc_FontTitle
            font.bold: true
            color:ScreenParams.colorText

            Layout.fillHeight: true
            Layout.fillWidth: true
        }



        RowLayout {
            id: row
            Layout.fillWidth: true
            height: ScreenParams.rc_ItemHeight
            Layout.margins:  ScreenParams.rc_ItemSpace
            Layout.columnSpan: ScreenParams.isPortrait?1:2
            spacing:  ScreenParams.rc_ItemSpace

            Button {
                id: btn_quit
                text: qsTr("Quit")
                Layout.fillWidth: true
                font.pixelSize: ScreenParams.rc_FontTitle
                onClicked: {
                    Qt.quit();
                }
            }

            Button {
                id: btn_Rotate
                text: qsTr("Rotate Screen")
                font.pixelSize: ScreenParams.rc_FontTitle
                onClicked: {
                    cfg_Rotation+=90;
                    if (cfg_Rotation >=280) cfg_Rotation=0;
                    mainpage.rotation=cfg_Rotation;
                }
            }


            Button {
                id: btn_cnx
                text: opc.stateReady ? qsTr("Disconnect") : qsTr("Connect")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.fillWidth: true
                font.pixelSize: ScreenParams.rc_FontTitle
                onClicked: {
                    if (opc.connected) {
                        opc.disconnect();
                    } else {
                        cfg_Url= txt_url.text  ;
                        cfg_Api_Key=txt_api_key.text;
                        cfg_UserName=txt_username.text;
                        cfg_printerPort=txt_port.text;
                        cfg_printerProfile=txt_profil.text;
                        opc.init();
                    }
                }
            }
        }
    }
}
