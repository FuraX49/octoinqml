import QtQml 2.3
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import "../Components"


Page {
    id : control
    property bool showFocusHighlight: true
    property alias mainMenu: mainMenu
    
    ListModel {
        id : mainMenu
    }
    


    /*
    Component {
        id : menuitem

        Item {
            id:  wrappper
            height : gridmenu.cellHeight
            width  : gridmenu.cellWidth
            Column {
                id: menuelem
                anchors.fill: parent
                anchors.margins: ScreenParams.rc_ItemSpace
                spacing: ScreenParams.rc_ItemSpace
                Image {
                    id:menuImage
                    source: icon
                    fillMode:  Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignHCenter
                    height : (gridmenu.cellHeight-menuText.height) * 0.8
                    width  : gridmenu.cellWidth * 0.8

                }

                Text {
                    id : menuText
                    text: title
                    width: menuImage.width
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: ScreenParams.rc_FontTitle
                    wrapMode: Text.WordWrap
                    font.bold: true
                }
            }
            
            
            MouseArea {
                anchors.fill: parent
                onClicked:{
                    menupage.showFocusHighlight=true;
                    wrappper.GridView.view.currentIndex = index;
                    gridmenu.currentIndexChanged();

                }
            }
        }
    }
*/
    Component {
        id : menuitem

        ToolButton {
            height : gridmenu.cellHeight
            width  : gridmenu.cellWidth
            icon.source: iconSource
            icon.width: gridmenu.cellWidth
            icon.height:gridmenu.cellWidth
            text : title
            font.pixelSize: ScreenParams.rc_FontTitle
            display : AbstractButton.TextUnderIcon
            font.bold: true
            onClicked:{
                menupage.showFocusHighlight=true;
                GridView.view.currentIndex = index;
                gridmenu.currentIndexChanged();
            }
        }
    }
    
    Component {
        id: highlight
        Rectangle {
            id : rectlight
            color:  control.palette.shadow
            opacity: 0.5
            width: gridmenu.cellWidth
            height:gridmenu.cellHeight
        }
    }


    GridView {
        id : gridmenu
        property int espace : ScreenParams.rc_ItemSpace *2
        anchors.fill: parent
        anchors.margins: ScreenParams.rc_ItemSpace

        model: mainMenu
        flow: ScreenParams.isPortrait ? GridLayout.TopToBottom : GridLayout.LeftToRight
        cellWidth: ScreenParams.isPortrait ? (width-espace) /2 : (width-espace)  /5
        cellHeight: ScreenParams.isPortrait ? (height-espace) /5 : (height-espace) /2
        delegate: menuitem
        highlight:  highlight
        highlightFollowsCurrentItem: menupage.showFocusHighlight
        highlightMoveDuration: 500
        snapMode: GridView.SnapOneRow
        focus: true
        onCurrentIndexChanged: {
            view.currentIndex=currentIndex+1;
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
