import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import "../Components"


PageTemplate {
    id: jogpage
    title: qsTr("Jog")
    implicitWidth: 800
    implicitHeight: 480
    icon.source: "../Images/jog.svg"



    function init(){
        opc.positionUpdate.connect(debugPosition);

        toolSelect.model=opc.extrudercount;
    }

    function debugPosition(X,Y,Z) {
        console.debug("X  "+X+"\tY "+Y+"\t Z "+Z);
    }

    GridLayout {
        id: grid
        columnSpacing: ScreenParams.rc_ItemSpace
        anchors.margins: ScreenParams.rc_ItemSpace
        rowSpacing: ScreenParams.rc_ItemSpace
        anchors.fill: parent
        flow: ScreenParams.isPortrait ?   GridLayout.TopToBottom : GridLayout.LeftToRight

        GridLayout {
            // ******** Col 0 ******************
            rows: 4
            columns: 3

            SvgButton {
                id: jogLeft
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 0
                Layout.row : 1
                Layout.fillHeight: true
                Layout.fillWidth: true
                rotation: 270
                icon.source:  "../Images/arrow.svg"
                onClicked: {
                    opc.post_printhead_jog("x",-joglength.displayText);
                }
            }


            // ******** Col 1 ******************
            SvgButton {
                id: jogUP
                text : ""
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 1
                Layout.row : 0
                Layout.fillHeight: true
                Layout.fillWidth: true
                icon.source : "../Images/arrow.svg"
                rotation:  0
                onClicked: {
                    opc.post_printhead_jog("y",+joglength.displayText);
                }

            }

            SvgButton {
                id : jogHome
                text : "X/Y"
                font.pixelSize:  ScreenParams.rc_FontTitle *2
                homebutton:  true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 1
                Layout.row : 1
                Layout.fillHeight: true
                Layout.fillWidth: true
                icon.source:  "../Images/home.svg"
                onClicked: {
                    opc.post_printhead_home('"x","y"');
                }
            }

            SvgButton {
                id: jogDown
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 1
                Layout.row : 2
                Layout.fillHeight: true
                Layout.fillWidth: true
                rotation: 180
                icon.source: "../Images/arrow.svg"
                onClicked: {
                    opc.post_printhead_jog("y",-joglength.displayText);
                }
            }

            // ******** Col 2 ******************
            SvgButton {
                id: jogRight
                text : ""
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 2
                Layout.row : 1
                Layout.fillHeight: true
                Layout.fillWidth: true
                rotation: 90
                icon.source: "../Images/arrow.svg"
                onClicked: {
                    opc.post_printhead_jog("x",+joglength.displayText);
                }
            }

            StepBox {
                id : joglength
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column :0
                Layout.row : 3
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 3
            }



        }
        GridLayout {
            rows: 4
            columns: 3
            // ******** Col 4 ******************
            SvgButton {
                id : headUp
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 0
                Layout.row : 0
                Layout.fillHeight: true
                Layout.fillWidth: true
                icon.source : "../Images/arrow.svg"
                rotation: 0
                onClicked: {
                    opc.post_printhead_jog("z",+joglength.displayText);
                }

            }


            SvgButton {
                id : lbZ
                homebutton: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pixelSize:  ScreenParams.rc_FontTitle *2
                text: "Z"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.column : 0
                Layout.row : 1
                icon.source : "../Images/home.svg"
                onClicked: {
                    opc.post_printhead_home('"z"');
                }

            }


            SvgButton {
                id : headDown
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 0
                Layout.row : 2
                Layout.fillHeight: true
                Layout.fillWidth: true
                icon.source : "../Images/arrow.svg"
                rotation: 180
                onClicked: {
                    opc.post_printhead_jog("z",-joglength.displayText);
                }
            }

            // ******** Col 5 ******************
            SvgButton {
                text : ""
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 1
                Layout.row : 0
                Layout.fillHeight: true
                Layout.fillWidth: true
                icon.source:  "../Images/fan-off.svg"
                onClicked: {
                    opc.post_printer_command("M107");
                }
            }

            SvgButton {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 1
                Layout.row : 1
                Layout.fillHeight: true
                Layout.fillWidth: true
                icon.source:  "../Images/fan-on.svg"

                onClicked: {
                    opc.post_printer_command("M106 S255");
                }
            }
            SvgButton {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 1
                Layout.row : 2
                Layout.fillHeight: true
                Layout.fillWidth: true
                icon.source:  "../Images/motor-off.svg"
                onClicked: {
                    opc.post_printer_command("M84");
                }
            }

            // ******** Col 6 ******************
            SvgButton {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 2
                Layout.row : 0
                Layout.fillHeight: true
                Layout.fillWidth: true
                icon.source : "../Images/arrow.svg"
                rotation: 0
                onClicked: {
                    opc.post_printer_tool_extrude(-extlength.displayText);
                }
            }


            Component {
                id: delegateComponent
                Label {
                    text: "E" + toolSelect.currentIndex
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize:  ScreenParams.rc_FontTitle *2
                }
            }


            Tumbler {
                id : toolSelect
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                model : 2
                delegate: delegateComponent
                visibleItemCount :1
                Layout.fillWidth: true
                Layout.maximumHeight: parent.height / 10
                Layout.column : 2
                Layout.row : 1
                onCurrentIndexChanged: {
                    opc.post_printer_tool_select(currentIndex.toString());
                }
            }



            SvgButton {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column : 2
                Layout.row : 2
                Layout.fillHeight: true
                Layout.fillWidth: true
                icon.source : "../Images/arrow.svg"
                rotation: 180
                onClicked: {
                    opc.post_printer_tool_extrude(+extlength.displayText);
                }
            }



            StepBox {
                id : extlength
                items: ["1", "5", "10","50"]
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.column :1
                Layout.row : 3
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 2
            }

        }

    }


}
