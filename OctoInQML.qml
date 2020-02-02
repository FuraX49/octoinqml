import QtQml 2.3
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.VirtualKeyboard 2.3
import Qt.labs.settings 1.0

import "./Pages" as Pages
import "./Components"
import "./Components/OctoPrintShared.js" as OPS

Item {
    id : rootscreen

    width:  800
    height: 480
    property alias lbStatus: lbStatus
    property alias  mainMenu : menupage.mainMenu

    property bool isLinuxPlatform:   Qt.platform.os === "linux"
    property bool isDarkTheme :   false

    // ************ SETTINGS ***************************************
    property string cfg_Url : "http://127.0.0.1:5000"
    property string cfg_Api_Key  :  "MODIFY"
    property string cfg_UserName :  "MODIFY"
    property string cfg_printerProfile :  "_default"
    property string cfg_printerPort :  "AUTO"
    property int    cfg_baudRate    :  115200
    property int    cfg_CnxInterval  :  10
    property string cfg_TempName1 :  "PLA"
    property string cfg_TempName2 :  "ABS"


    property string cfg_RegExpTemp : 'Suppress temperature messages'
    property string cfg_RegExpSD : 'Suppress SD status messages'
    property string cfg_RegExpWait: 'Suppress wait responses'

    property int  cfg_Rotation : 0
    property string  cfg_Page0  : ""
    property string  cfg_Page1  : ""
    property string  cfg_Page2  : ""
    property string  cfg_Page3  : ""
    property string  cfg_Page4  : ""
    property string  cfg_Page5  : ""
    property string  cfg_Page6  : ""
    property string  cfg_Page7  : ""
    property string  cfg_Page8  : ""
    property string  cfg_Page9  : ""


    property int errortype : 0

    Settings {
        id: octoSettings
        category : "OctoPrint"
        property alias url : rootscreen.cfg_Url
        property alias apikey: rootscreen.cfg_Api_Key
        property alias username: rootscreen.cfg_UserName
        property alias printerProfile: rootscreen.cfg_printerProfile
        property alias cnxInterval : rootscreen.cfg_CnxInterval
    }

    Settings {
        id: printerSettings
        category : rootscreen.cfg_printerProfile.toString()
        property alias printerPort : rootscreen.cfg_printerPort
        property alias baudRate    : rootscreen.cfg_baudRate
        property alias tempName1   : rootscreen.cfg_TempName1
        property alias tempName2   : rootscreen.cfg_TempName2
        property alias regExpTemp  : rootscreen.cfg_RegExpTemp
        property alias regExpSD    : rootscreen.cfg_RegExpSD
        property alias regExpWait  : rootscreen.cfg_RegExpWait
    }

    Settings {
        id: pagesConf
        category : "Pages"
        property alias page0 : rootscreen.cfg_Page0
        property alias page1 : rootscreen.cfg_Page1
        property alias page2 : rootscreen.cfg_Page2
        property alias page3 : rootscreen.cfg_Page3
        property alias page4 : rootscreen.cfg_Page4
        property alias page5 : rootscreen.cfg_Page5
        property alias page6 : rootscreen.cfg_Page6
        property alias page7 : rootscreen.cfg_Page7
        property alias page8 : rootscreen.cfg_Page8
        property alias page9 : rootscreen.cfg_Page9

        property alias rotation: rootscreen.cfg_Rotation
    }

    function init() {
        if (cfg_Page0) page0.setUrl(rootscreen.cfg_Page0);
        if (cfg_Page1) page1.setUrl(rootscreen.cfg_Page1);
        if (cfg_Page2) page2.setUrl(rootscreen.cfg_Page2);
        if (cfg_Page3) page3.setUrl(rootscreen.cfg_Page3);
        if (cfg_Page4) page4.setUrl(rootscreen.cfg_Page4);
        if (cfg_Page5) page5.setUrl(rootscreen.cfg_Page5);
        if (cfg_Page6) page6.setUrl(rootscreen.cfg_Page6);
        if (cfg_Page7) page7.setUrl(rootscreen.cfg_Page7);
        if (cfg_Page8) page8.setUrl(rootscreen.cfg_Page8);
        if (cfg_Page9) page9.setUrl(rootscreen.cfg_Page9);

        if ((cfg_Api_Key==="MODIFY") ||   (cfg_UserName==="MODIFY")     ) {
            busy.running=false;
            errorPopup.showError("ERROR Configuration ","Edit  /etc/octoinqml/QtProject/QtQmlViewer.conf and modify configuration. ");
        }  else {
            opc.init();
        }
    }

    OctoPrintClient {
        id : opc
        debug: false
        url: cfg_Url
        apikey: cfg_Api_Key
        username: cfg_UserName
        printerProfile  : cfg_printerProfile
        printerPort : cfg_printerPort
        printerbaudRate : cfg_baudRate
        intervalcnx:  cfg_CnxInterval


        onStateTextChanged: {
            lbStatus.text=opc.stateText;
        }

        onTryConnect:  {
            lbStatus.text= "Try connect octoprint " + cnttry;
        }

        onConnectedChanged: {
            if (opc.connected) {
                console.info("Connected at : " + Date());
                busy.running = false;

                opc.get_printerprofiles();

                if ((page0.item) && (typeof page0.item.init === 'function')) page0.item.init();
                if ((page1.item) && (typeof page1.item.init === 'function')) page1.item.init();
                if ((page2.item) && (typeof page2.item.init === 'function')) page2.item.init();
                if ((page3.item) && (typeof page3.item.init === 'function')) page3.item.init();
                if ((page4.item) && (typeof page4.item.init === 'function')) page4.item.init();
                if ((page5.item) && (typeof page5.item.init === 'function')) page5.item.init();
                if ((page6.item) && (typeof page6.item.init === 'function')) page6.item.init();
                if ((page7.item) && (typeof page7.item.init === 'function')) page7.item.init();
                if ((page8.item) && (typeof page8.item.init === 'function')) page8.item.init();
                if ((page9.item) && (typeof page9.item.init === 'function')) page9.item.init();
            }
        }


        onShowError: {
            busy.running = false;
            errorPopup.standardButtons= Dialog.Ok;
            errortype=0;
            errorPopup.showError(titlerr,msgerr);
        }


        onStateClosedOrErrorChanged: {
            if (stateClosedOrError ) {
                stateOperational = false;
                stateReady  = false;
                statePrinting  = false;
                stateText="OffLine"
            }
        }

    }

    Page {
        id : mainpage
        visible: true
        title: qsTr("Toggle In QML")
        anchors.centerIn: parent
        header : maintoolBar
        width : parent.width
        height: parent.height
        spacing: 0
        padding: 0
        contentHeight: rootscreen.height - maintoolBar.height
        rotation: cfg_Rotation

        onRotationChanged: {
            if(cfg_Rotation === 90 )  {
                mainpage.rotation = 90;
                mainpage.width = rootscreen.height;
                mainpage.height = rootscreen.width
            } else if(cfg_Rotation === 0) {
                mainpage.rotation = 0;
                mainpage.width = rootscreen.width ;
                mainpage.height = rootscreen.height;
            }  else if(cfg_Rotation === 270) {
                mainpage.rotation = 270;
                mainpage.width = rootscreen.height;
                mainpage.height = rootscreen.width;
            }   else if(cfg_Rotation === 180) {
                mainpage.rotation = 180;
                mainpage.width = rootscreen.width ;
                mainpage.height = rootscreen.height;
            }

            ScreenParams.rescaleApplication(mainpage.width,mainpage.height);
        }


        ToolBar {
            id: maintoolBar
            contentWidth:  rootscreen.width
            contentHeight: ScreenParams.rc_ItemHeight

            RowLayout {
                anchors.fill: parent
                id: rowLayout

                ToolButton {
                    font.pixelSize:  ScreenParams.rc_FontTitle
                    text: "Menu"
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    icon.source:  "Images/menu.svg"
                    onClicked: {
                        view.currentIndex=0;
                    }

                }

                Label {
                    id : lbStatus
                    font.pixelSize:  ScreenParams.rc_FontTitle
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    elide: Text.ElideLeft
                    text:opc.stateText;
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    textFormat: Text.PlainText
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

            }
        }

        StackLayout  {
            id : view
            currentIndex:-1
            anchors.centerIn: parent
            anchors.fill: parent

            Pages.MenuPage {
                id: menupage
            }

        }

        PageLoader {id : page0}
        PageLoader {id : page1}
        PageLoader {id : page2}
        PageLoader {id : page3}
        PageLoader {id : page4}
        PageLoader {id : page5}
        PageLoader {id : page6}
        PageLoader {id : page7}
        PageLoader {id : page8}
        PageLoader {id : page9}


        BusyIndicator {
            id : busy
            height: parent.width /2
            width: height
            x: Math.round(parent.width - width) / 2
            y: Math.round(parent.height - height) / 2
            Image {
                anchors.centerIn: parent
                source: "Images/octoprint.png"
                visible: busy.running
            }
        }


        ErrorPopup {
            id: errorPopup
            standardButtons: Dialog.Ok

            onAccepted: {
                console.log("error accepted")
            }

        }



    }

    // ******** VirtualKeyboard **********************
    InputPanel {
        id: inputPanel
        z: 9999
        x: 0
        y: mainpage.height
        width: mainpage.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: mainpage.height - inputPanel.height -25
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    // run init after all component ready
    Timer {
        id : timerstart
        repeat : false
        interval : 2000
        running : false
        triggeredOnStart : false
        onTriggered: {
            rootscreen.init();
        }
    }


    Component.onCompleted: {

        isDarkTheme  = ( lbStatus.color.r + lbStatus.color.g + lbStatus.color.b)  > 1.5;
        ScreenParams.colorText = lbStatus.color

        ScreenParams.rescaleApplication(mainpage.width,mainpage.height);
        timerstart.start();
    }

}



