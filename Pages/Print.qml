import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import "../Components"
import "../Components/OctoPrintShared.js" as OPS

PageTemplate {
    id: printpage
    title: qsTr("Print")
    icon.source: "../Images/print.svg"
    
    implicitWidth: 800
    implicitHeight: 480
    
    function init(){
        
        opc.tempChanged.connect(updateTemps);
        opc.progressChanged.connect(updateProgress);
        opc.jobChanged.connect(updateJob);
        
        opc.get_settings();
        opc.get_job();
        
        updateProgress();
        updateJob();
        
        if (opc.heatedBed) {
            bed.visible=true;
            bed.temp1=OPS.temp1.bed;
            bed.temp2=OPS.temp2.bed;
        }
        
        /* Not Ready
        if (opc.heatedChamber) {
            chamber.visible=true;
            chamber.temp1=OPS.temp1.chamber;
            chamber.temp2=OPS.temp2.chamber;
        }
        */
        
        tool0.temp1=OPS.temp1.extruder;
        tool0.temp2=OPS.temp2.extruder;
        
        if (opc.extrudercount>1) {
            tool1.temp1=OPS.temp1.extruder;
            tool1.temp2=OPS.temp2.extruder;
            tool1.visible=true;
        }
        if (opc.extrudercount>2) {
            tool2.temp1=OPS.temp1.extruder;
            tool2.temp2=OPS.temp2.extruder;
            tool2.visible=true;
        }
        if (opc.extrudercount>3) {
            tool3.temp1=OPS.temp1.extruder;
            tool3.temp2=OPS.temp2.extruder;
            tool3.visible=true;
        }
        
    }
    
    function updateTemps(history, heure){
        if (!history ) {
            if (bed.visible) bed.updateTemps(OPS.temps.bed.actual,OPS.temps.bed.target);
            //if (chamber.visible) chamber.updateTemps(OPS.temps.chamber.actual,OPS.temps.chamber.target);
            tool0.updateTemps(OPS.temps.tool0.actual,OPS.temps.tool0.target);
            if (tool1.visible) tool1.updateTemps(OPS.temps.tool1.actual,OPS.temps.tool1.target);
            if (tool2.visible) tool2.updateTemps(OPS.temps.tool2.actual,OPS.temps.tool2.target);
            if (tool3.visible) tool3.updateTemps(OPS.temps.tool3.actual,OPS.temps.tool3.target);
        }
    }
    
    function updateProgress(){
        lb_printTime.text =OPS.formatMachineTimeString(OPS.progress.printTime);
        lb_printTimeLeftOrigin.text=(OPS.progress.printTimeLeftOrigin)?OPS.progress.printTimeLeftOrigin:"";
        lb_printTimeLeft.text = OPS.formatMachineTimeString(OPS.progress.printTimeLeft);
        progressBar.value=(OPS.progress.completion)?OPS.progress.completion:0;
    }
    
    function razProgress() {
        progressBar.value=0.0;
    }
    
    function updateJob(){
        lbFileSelected.text=OPS.job.file.path;
        lb_printTimeLeft.text = OPS.formatMachineTimeString(OPS.job.estimatedPrintTime);
        
    }



    RowLayout {
        id: rowJob
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: ScreenParams.rc_ItemSpace
        Layout.minimumHeight:  ScreenParams.rc_ItemHeight * 3

        ColumnLayout {
            id: columnLayout
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: ScreenParams.rc_ItemSpace

            Label {
                id: lbFileSelected
                text: ".."
                Layout.fillHeight: true
                font.pixelSize: ScreenParams.rc_FontTitle
                Layout.minimumHeight:  ScreenParams.rc_ItemHeight
                Layout.fillWidth: true

            }

            ProgressBar {
                id: progressBar
                Layout.fillHeight: true
                Layout.minimumHeight:  ScreenParams.rc_ItemHeight
                Layout.fillWidth: true

                from : 0.0
                value: 0.0
                to :100.0

                background: Rectangle {
                    width: parent.width
                    height: parent.height
                    color: progressBar.palette.button
                    radius: 3
                }
                contentItem: Item {
                    width:  parent.width
                    height: parent.height/4

                    Rectangle {
                        width: progressBar.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color:  progressBar.palette.highlight
                    }
                    Text {
                        id: name
                        text: progressBar.value.toFixed(2).toString() + "%";
                        verticalAlignment: Text.AlignVCenter
                        font.weight: Font.Light
                        color: progressBar.palette.buttonText
                        font.pixelSize: ScreenParams.rc_FontBig
                        width : parent.width
                        height: parent.height
                    }
                }


            }

            RowLayout {
                Layout.fillHeight: true
                Layout.minimumHeight: ScreenParams.rc_ItemHeight
                Layout.fillWidth: true


                Label {
                    id : lb_printTime
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: ScreenParams.rc_FontBig
                    text : "0 min"
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    id : lb_printTimeLeftOrigin
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: ScreenParams.rc_FontBig
                    text : "_"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    id : lb_printTimeLeft
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: ScreenParams.rc_FontBig
                    text : "0 min"
                    horizontalAlignment: Text.AlignLeft
                }
            }
        }
    }

    //RowLayout {
    GridLayout {
        id: rowTool
        anchors.top: rowJob.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: ScreenParams.rc_ItemSpace
        Layout.minimumHeight: ScreenParams.isPortrait ?  ScreenParams.rc_ItemHeight * 6 : ScreenParams.rc_ItemHeight * 3
        rows:  ScreenParams.isPortrait ?  2 : 1
        columns: ScreenParams.isPortrait ?  2 : 4

        Heater {
            id :bed
            title: "Bed"
            visible: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            onPreheatChange: {
                opc.post_bed_target(temperature);
            }
        }

        Heater {
            id :chamber
            title: "Chamber"
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            onPreheatChange: {
                opc.post_chamber_target(temperature);
            }
        }

        Heater {
            id :tool0
            objectName: "Tool0"
            Layout.fillWidth: true
            Layout.fillHeight: true
            onPreheatChange: {
                opc.post_tool_target(objectName,temperature);
            }

        }

        Heater {
            id :tool1
            objectName:  "Tool1"
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            onPreheatChange: {
                opc.post_tool_target(objectName,temperature);
            }
        }

        Heater {
            id :tool2
            visible: false
            objectName:  "Tool2"
            Layout.fillWidth: true
            Layout.fillHeight: true
            onPreheatChange: {
                opc.post_tool_target(objectName,temperature);
            }
        }

        Heater {
            id :tool3
            objectName:  "Tool3"
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            onPreheatChange: {
                opc.post_tool_target(objectName,temperature);
            }
        }
    }

    RowLayout {
        id: rowPrint
        anchors.bottom: parent.bottom
        anchors.top: rowTool.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: ScreenParams.rc_ItemSpace
        //Layout.minimumHeight:  ScreenParams.rc_ItemHeight * 2
        Layout.maximumHeight:  ScreenParams.rc_ItemHeight * 2

        SvgButton {
            autoRepeat: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon.source :"../Images/play.svg"
            icon.color:  opc.statePrinting?palette.link: ScreenParams.colorText
            enabled: opc.stateOperational && opc.stateReady && !opc.statePrinting && !opc.stateCancelling && !opc.statePausing  && opc.stateFileSelected;
            opacity: enabled ? 1.0 : 0.2
            onClicked: {
                if (opc.statePaused) {
                    opc.post_job_command('"restart"');
                } else {
                    opc.post_job_command('"start"');

                }
            }
        }

        SvgButton {
            autoRepeat: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon.source :"../Images/pause.svg"
            icon.color: opc.statePaused? palette.link: ScreenParams.colorText
            opacity: enabled ? 1.0 : 0.2
            enabled: opc.stateOperational && ( opc.statePrinting || opc.statePaused)  && !opc.stateCancelling && !opc.statePausing
            onClicked: {
                if (opc.statePaused) {
                    opc.post_job_command('"pause" , "action": "resume"');
                } else {
                    opc.post_job_command('"pause" , "action": "pause"');
                }
            }
        }

        SvgButton {
            autoRepeat: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon.source :"../Images/cancel.svg"
            enabled: opc.stateOperational && ( opc.statePrinting || opc.statePaused)  && !opc.stateCancelling && !opc.statePausing
            opacity: enabled ? 1.0 : 0.2
            onClicked: {
                opc.post_job_command('"cancel"');
            }
        }
    }
}
















