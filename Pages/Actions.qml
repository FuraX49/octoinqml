import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Layouts 1.3

import "../Components"

PageTemplate {
    id: commandspage
    title: qsTr("Commands")
    icon.source:  "../Images/actions.svg"
    implicitWidth: 800
    implicitHeight: 480
    property bool showFocusHighlight: false
    property int rc_heightcmd : 50
    property string actionText: ""
    property string sourceText: ""

    function init(){
        opc.get_system_commands();
        rc_heightcmd = (commandspage.height- listView.anchors.margins*2) / (opc.actionsmodel.count+1) ;
    }

    Component {
        id: highlight
        Rectangle {
            id : rect
            width: listView.width
            height : rc_heightcmd
            color: palette.highlight
            opacity: 0.5
            radius: 5
            y: (listView.currentIndex>-1)?listView.currentItem*ScreenParams.rc_heightcmd + (ScreenParams.rc_ItemSpace*2) : 0
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }


    Component {
        id : actionsDelegate

        Item {
            id:  wrappper
            anchors { left: parent.left; right: parent.right  }
            height : rc_heightcmd
            Item {
                id :rowdelegate
                anchors.margins: ScreenParams.rc_ItemSpace
                anchors.fill: parent
                Text {
                    id : actionid
                    text: action
                    visible: false
                }

                Text {
                    id : nameid
                    text: name
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    //elide: Text.ElideMiddle
                    maximumLineCount: 3
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 12
                    font.pixelSize: ScreenParams.rc_ItemHeight
                    font.bold:false
                    font.italic : (source==="core")?true:false
                    visible: true
                    color: ScreenParams.colorText
                    wrapMode: Text.WordWrap

                }



                Text {
                    id : sourceid
                    text: source
                    visible: false
                }

                Text {
                    id : confirmid
                    text: (confirm)?confirm:""
                    visible: false
                }


            }
            MouseArea {
                anchors.fill: parent
                onClicked:{
                    showFocusHighlight=true;
                    wrappper.ListView.view.currentIndex = index;
                }
                onDoubleClicked: {
                    sourceText=sourceid.text;
                    actionText=actionid.text;
                    if (confirmid.text.length>0) {
                        actionPopup.confirm(nameid.text,confirmid.text);
                    } else {
                        opc.post_system_commands(sourceText,actionText);
                    }
                }
            }

        }
    }


    ListView {
        id: listView
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: ScreenParams.rc_ItemSpace
        spacing: 0
        flickableDirection: Flickable.AutoFlickDirection
        highlight: highlight
        highlightFollowsCurrentItem: showFocusHighlight
        focus: true
        model:  opc.actionsmodel
        delegate: actionsDelegate
    }

    ActionPopup {
        id : actionPopup
        standardButtons: Dialog.Ok  | Dialog.Cancel
        onAccepted: {
            opc.post_system_commands(sourceText,actionText);
        }

    }




}


