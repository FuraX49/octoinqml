import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Layouts 1.3

import "../Components"

PageTemplate {
    id: filespage
    objectName: "filespage"
    title: qsTr("Files")
    icon.source: "../Images/files.svg"

    implicitWidth: 800
    implicitHeight: 480

    property string originsel
    property string pathsel
    property bool showFocusHighlight: false
    property string  location: "local"

    function init(){
        fileview.currentIndex=-1;
        opc.get_files(location);
    }

    Component {
        id: highlight
        Rectangle {
            width: fileview.width
            height : ScreenParams.isPortrait? ScreenParams.rc_ItemHeight*1.3:ScreenParams.rc_ItemHeight
            color: palette.highlight
            opacity: 0.5
            radius: 5
            y: (fileview.currentIndex>-1)?fileview.currentItem*fileview.height / 20 : 0
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }



    Component {
        id : colHeader

        Rectangle {
            id : rectHeader
            anchors { left: parent.left; right: parent.right }
            height : ScreenParams.rc_ItemHeight
            color: palette.highlight
            border.width: 2
            radius: 2
            MouseArea {
                anchors.fill: parent
                onDoubleClicked: {
                    init();
                }
            }



            Row  {
                id : rowheader
                anchors { fill: parent; margins: 2 }
                Text {
                    id: name
                    width: Math.floor(parent.width * 0.60)
                    font.bold: true
                    font.pixelSize: ScreenParams.rc_FontBig
                    text: qsTr("Name")
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    id: size
                    font.bold: true
                    font.pixelSize: ScreenParams.rc_FontBig
                    width: Math.floor(parent.width * 0.15)
                    text: qsTr("Size")
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    id: date
                    font.bold: true
                    font.pixelSize: ScreenParams.rc_FontBig
                    width: Math.floor(parent.width * 0.25)
                    text: qsTr("Date")
                    horizontalAlignment: Text.AlignHCenter
                }

            }
        }
    }



    Component {
        id : filesDelegate
        Item {
            id:  wrappper
            anchors { left: parent.left; right: parent.right }
            height : ScreenParams.isPortrait? ScreenParams.rc_ItemHeight*1.3:ScreenParams.rc_ItemHeight

            Flow {
                id :rowdelegate
                anchors { fill: parent; margins: 2 }
                Text {
                    id : filename
                    text: display
                    font.bold: (type!=='folder')?false:true
                    font.pixelSize: ScreenParams.rc_FontBig
                    color: ScreenParams.colorText
                    width: ScreenParams.isPortrait?parent.width:Math.floor(parent.width * 0.60)
                    elide:  Text.ElideRight
                }

                Text {
                    id : filesize
                    text:(type!=='folder')?Math.round(size/1024) +" Kb" : ""
                    horizontalAlignment: Text.AlignRight
                    elide:  Text.ElideLeft
                    font.bold: false
                    font.pixelSize: ScreenParams.rc_FontBig
                    color: ScreenParams.colorText
                    width: ScreenParams.isPortrait?Math.floor(parent.width * 0.40):Math.floor(parent.width * 0.15)
                }
                Text {
                    id : filedate
                    text: ((type!=='folder') && (origin==='local')) ?new Date(date*1000).toLocaleString(locale,"yyyy/MM/dd HH:mm:ss"):""
                    horizontalAlignment: Text.AlignRight
                    elide:  Text.ElideRight
                    font.bold: false
                    font.pixelSize: 0
                    color: ScreenParams.colorText
                    width: ScreenParams.isPortrait?Math.floor(parent.width * 0.60):Math.floor(parent.width * 0.25)
                }
                Text {
                    id : reforigin
                    text: origin
                    visible: false
                }
                Text {
                    id : refpath
                    text: path
                    visible: false
                }

            }
            MouseArea {
                anchors.fill: parent
                onClicked:{
                    showFocusHighlight=true;
                    wrappper.ListView.view.currentIndex = index;
                    originsel=reforigin.text
                    //pathsel=refpath.text;
                }
                onDoubleClicked:  {
                    if (type==='folder') {
                        showFocusHighlight=false;
                        opc.get_files(location,refpath.text);
                        fileview.currentIndex=-1;
                    } else {
                        originsel=reforigin.text
                        pathsel=refpath.text;
                        opc.post_files_select(location,pathsel);
                    }
                }

            }
        }
    }


    ListView {
        id : fileview
        anchors.bottomMargin: ScreenParams.rc_ItemSpace
        anchors.margins: ScreenParams.rc_ItemSpace
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: lbPath.top
        anchors.left: parent.left
        flickableDirection: Flickable.AutoFlickDirection
        highlight: highlight
        highlightFollowsCurrentItem: showFocusHighlight
        focus: true
        header: colHeader
        headerPositioning  : ListView.PullBackHeader
        model:  opc.filesmodel
        delegate: filesDelegate
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            active: true
            interactive : true
            orientation: Qt.Vertical
            policy : ScrollBar.AlwaysOn
        }
    }




    Label {
        id: lbPath
        text: pathsel
        anchors.right: btnInfo.left
        anchors.rightMargin: ScreenParams.rc_ItemSpace
        anchors.left: parent.left
        anchors.leftMargin: ScreenParams.rc_ItemSpace
        anchors.bottom: parent.bottom
        anchors.bottomMargin: ScreenParams.rc_ItemSpace
        height: ScreenParams.rc_ItemHeight
        verticalAlignment: Text.AlignVCenter
        font.italic: true
        font.bold:  true
        font.pixelSize: ScreenParams.rc_FontBig
    }


    Button {
        id: btnSD
        text: qsTr("SDCard")
        font.pixelSize: ScreenParams.rc_FontBig
        checkable: true
        checked : true
        enabled: opc.sdSupport
        visible: opc.sdSupport
        height: ScreenParams.rc_ItemHeight
        anchors.right: btnInfo.left
        anchors.rightMargin: ScreenParams.rc_ItemSpace
        anchors.bottom: parent.bottom
        anchors.bottomMargin: ScreenParams.rc_ItemSpace
        icon.source: checked ? "../Images/sdcard.svg" : "../Images/disk.svg"
        onClicked: {
            if (checked)  {
                location='local';
                text=qsTr("SDCard");
            } else {
                location='sdcard';
                text=qsTr("Local");
            }
            opc.get_files(location);
        }
    }

    Button {
        id: btnInfo
        text: qsTr("Info")
        font.pixelSize: ScreenParams.rc_FontBig
        enabled: opc.stateFileSelected
        visible:  (location==='local');
        height: ScreenParams.rc_ItemHeight
        anchors.right: parent.right
        anchors.rightMargin: ScreenParams.rc_ItemSpace
        anchors.bottom: parent.bottom
        anchors.bottomMargin: ScreenParams.rc_ItemSpace
        onClicked: {
            infoPopup.showInfo();
        }
    }

    InfoPopup {
        id : infoPopup
    }


}
