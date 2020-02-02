import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import "../Components"
import "../Components/OctoPrintShared.js" as OPS

PageTemplate {
    id: pageterminal
    title: "Terminal"
    icon.source   : "../Images/terminal.svg"
    property bool  scrollbusy: false
    property int  cfg_LinesBuffer : 50


    function init(){
      opc.logChanged.connect(addLogs);
    }

    function addLogs( log) {
        if (!cb_log.checked ) {

            var temp = log.match(OPS.regTemp) ;
            var wait = log.match(OPS.regWait);
            var sd   = log.match(OPS.regSD);

            if ((  temp ) &&  (!cb_temp.checked) ) {
                modellog.append({"line": log });
            } else if ( (wait)  && (!cb_wait.checked)) {
                modellog.append({"line": log });
            } else  if ( (sd )  && (!cb_sd.checked)) {
                modellog.append({"line": log });
            } else if (!temp && !wait && !sd) {
                modellog.append({"line": log });
            }

            if (modellog.count>cfg_LinesBuffer) {
                modellog.remove(0);
                if (!scrollbusy) {
                    scrollBar.position=1.0;
                }
            }
        }
    }

    Settings {
        id: viewSettings
        category : "Terminal"
        property alias linesBuffer : pageterminal.cfg_LinesBuffer
    }

    RowLayout {
        id: rowLayout
        anchors.top: parent.top
        anchors.topMargin: ScreenParams.rc_ItemSpace
        anchors.right: parent.right
        anchors.rightMargin: ScreenParams.rc_ItemSpace
        anchors.left: parent.left
        anchors.leftMargin: ScreenParams.rc_ItemSpace
        height: ScreenParams.rc_ItemHeight *1.5
        z : 99

        TextField {
            id: textcmd
            text: "M115"
            Layout.minimumWidth: parent.width * 0.3
            font.pixelSize: ScreenParams.rc_FontBig
            Layout.fillHeight: true
            Layout.fillWidth: true
            onAccepted: {
                opc.post_printer_command(textcmd.text.toString());
            }
        }

        Button {
            id: toolButton
            text: qsTr("Send")
            font.pixelSize:ScreenParams.rc_FontBig
            highlighted: false
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                opc.post_printer_command(textcmd.text.toString());
            }
        }

        CheckBox {
            id: cb_log
            text: qsTr("log")
            font.pixelSize:ScreenParams.rc_FontBig
            checked: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: "Suppress all log messages"
            ToolTip.visible: hovered
            onCheckedChanged: {
                cb_temp.enabled=!cb_log.checked;
                cb_sd.enabled=!cb_log.checked;
                cb_wait.enabled=!cb_log.checked;
            }
        }

        CheckBox {
            id: cb_temp
            text: qsTr("Temp")
            font.pixelSize:ScreenParams.rc_FontBig
            checked: true
            enabled: false
            Layout.fillHeight: true
            Layout.fillWidth: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: "Suppress temperatures messages"
            ToolTip.visible: hovered
        }
        CheckBox {
            id: cb_sd
            text: qsTr("SD")
            font.pixelSize:ScreenParams.rc_FontBig
            checked: true
            enabled: false
            Layout.fillHeight: true
            Layout.fillWidth: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: "Suppress SD messages"
            ToolTip.visible: hovered
        }
        CheckBox {
            id: cb_wait
            text: qsTr("Wait")
            font.pixelSize:ScreenParams.rc_FontBig
            checked: true
            enabled: false
            Layout.fillHeight: true
            Layout.fillWidth: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: "Suppress wait/ok messages"
            ToolTip.visible: hovered
        }
    }

    ListModel {
        id : modellog
        ListElement {
            line: ""
        }
    }


    ListView {
        id: logList
        anchors.top: rowLayout.bottom
        anchors.margins: ScreenParams.rc_ItemSpace
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        model: modellog
        highlightFollowsCurrentItem: true
        focus: false
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            active: true
            interactive : true
            orientation: Qt.Vertical
            policy : ScrollBar.AlwaysOn
            minimumSize: 0
            size:cfg_LinesBuffer
            onPressedChanged: {
                scrollbusy=pressed;
            }
        }

        delegate:
            Text {
            id: textLogs_Id
            text: {text: line }
            font.pixelSize:ScreenParams.rc_FontNormal
            color: ScreenParams.colorText
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }








}
