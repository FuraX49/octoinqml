import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtCharts 2.0
import Qt.labs.settings 1.0
import "../Components"
import "../Components/OctoPrintShared.js" as OPS


PageTemplate {
    id: graphpage
    title: qsTr("Graph")
    implicitWidth: 800
    implicitHeight: 480

    icon.source : "../Images/graph.svg"
    property int maxGraphHist : 400
    property int cptGraphUpdate : 5
    property int cptUpdate: cptGraphUpdate


    function init() {
        opc.tempChanged.connect(graphUpdate);

        graphUpdate();

        bedactual.visible=opc.heatedBed;
        bedtarget.visible=opc.heatedBed;

        /* Not Ready
        chamberactual.visible=opc.heatedChamber;
        chambertarget.visible=opc.heatedChamber;
        */

        tool1actual.visible=(opc.extrudercount>1);
        tool1target.visible=(opc.extrudercount>1);

        tool2actual.visible=(opc.extrudercount>2);
        tool2target.visible=(opc.extrudercount>2);

        tool3actual.visible=(opc.extrudercount>3);
        tool3target.visible=(opc.extrudercount>3);
        maxGraphHist=chart.plotArea.width-4;


    }



    function graphUpdate( history, heure) {
        // Graph update 1/5 to reduce CPU (20% on BeagleBone !)
        if (cptUpdate===0  ) {
            chart.enabled=false;
            var maxpoint = false;

            if (!OPS.serverTime) {
                OPS.serverTime=heure;
            }

            tool0actual.append(OPS.serverTime,OPS.temps.tool0.actual);
            tool0target.append(OPS.serverTime,OPS.temps.tool0.target);
            if (tool0actual.count>=maxGraphHist ) {
                tool0actual.remove(0);
                tool0target.remove(0);
                maxpoint=true;
            } else {
                maxpoint=false;
            }

            if (opc.extrudercount>1) {
                tool1actual.append(OPS.serverTime,OPS.temps.tool1.actual);
                tool1target.append(OPS.serverTime,OPS.temps.tool1.target);
                if (maxpoint ) {
                    tool1actual.remove(0);
                    tool1target.remove(0);
                }
            }

            if (opc.extrudercount>2) {
                tool2actual.append(OPS.serverTime,OPS.temps.tool2.actual);
                tool2target.append(OPS.serverTime,OPS.temps.tool2.target);
                if (maxpoint ) {
                    tool2actual.remove(0);
                    tool2target.remove(0);
                }
            }
            if (opc.extrudercount>3) {
                tool3actual.append(OPS.serverTime,OPS.temps.tool3.actual);
                tool3target.append(OPS.serverTime,OPS.temps.tool3.target);
                if (maxpoint) {
                    tool3actual.remove(0);
                    tool3target.remove(0);
                }
            }
            if (opc.heatedBed) {
                bedactual.append(OPS.serverTime,OPS.temps.bed.actual);
                bedtarget.append(OPS.serverTime,OPS.temps.bed.target);
                if (maxpoint ) {
                    bedactual.remove(0);
                    bedtarget.remove(0);
                }
            }
            /* Not Ready
            if (opc.heatedChamber) {
                chamberactual.append(OPS.serverTime,OPS.temps.chamber.actual);
                chambertarget.append(OPS.serverTime,OPS.temps.chamber.target);
                if (maxpoint ) {
                    bedactual.remove(0);
                    bedtarget.remove(0);
                }
            }
            */

            axisX.max=new Date(OPS.serverTime);
            axisX.min=new Date( tool0actual.at(0).x);
            chart.enabled=true;
        }
        cptUpdate++;
        if (cptUpdate>cptGraphUpdate) cptUpdate=0;
    }

    Settings {
        id: graphSettings
        category : "Graph"
        property alias cptUpdate : graphpage.cptGraphUpdate
    }

    ChartView {
        id : chart
        anchors.fill: parent
        enabled: graphpage.visible
        anchors.margins: 0
        antialiasing: false
        animationOptions :ChartView.NoAnimation
        theme: isDarkTheme?ChartView.ChartThemeDark:ChartView.ChartThemeLight

        legend {
            visible: false
            alignment : Qt.AlignBottom
            showToolTips : false
            backgroundVisible : false
        }

        DateTimeAxis {
            id: axisX
            titleText: "time"
            format: "HH:mm"
            titleVisible: false
        }

        ValueAxis {
            id: axisY
            min: 0
            max: 300
            tickCount: 5
            titleText: "°C"
            titleVisible: false
        }

        ValueAxis {
            id: bedaxisY
            min: 0
            max: 120
            tickCount: axisY.tickCount
        }


        LineSeries {
            id: bedactual
            visible: false
            axisX: axisX
            axisYRight: bedaxisY
            name: "Bed"
        }

        LineSeries {
            id: bedtarget
            visible: false
            color: bedactual.color
            style :  Qt.DashLine
            axisX: axisX
            axisYRight: bedaxisY
        }

        LineSeries {
            id: chamberactual
            visible: false
            axisX: axisX
            axisYRight: bedaxisY
            name: "Chamber"
        }

        LineSeries {
            id: chambertarget
            visible: false
            style :  Qt.DashLine
            color: chamberactual.color
            axisX: axisX
            axisYRight: bedaxisY
        }


        LineSeries {
            id: tool0actual
            visible: true
            axisX: axisX
            axisY: axisY
            name: "Tool0"

            /* DateTimeAxis only updated on Tool0  don't works ? !!
                onPointRemoved: {
                    axisX.min= new Date( at(0).x);
                }
                onPointsRemoved: {
                    axisX.min= new Date( at(1).x);
                }*/

        }

        LineSeries {
            id: tool0target
            visible: true
            style :  Qt.DashLine
            color: tool0actual.color
            axisX: axisX
            axisY: axisY
        }

        LineSeries {
            id: tool1actual
            visible: false
            axisX: axisX
            axisY: axisY
            name: "Tool1"

        }

        LineSeries {
            id: tool1target
            visible: false
            style :  Qt.DashLine
            color: tool1actual.color
            axisX: axisX
            axisY: axisY
        }



        LineSeries {
            id: tool2actual
            visible: false
            axisX: axisX
            axisY: axisY
            name: "Tool2"

        }

        LineSeries {
            id: tool2target
            visible: false
            style :  Qt.DashLine
            color: tool2actual.color
            axisX: axisX
            axisY: axisY
        }

        LineSeries {
            id: tool3actual
            visible: false
            axisX: axisX
            axisY: axisY
            name: "Tool3"

        }

        LineSeries {
            id: tool3target
            visible: false
            style :  Qt.DashLine
            color: tool3actual.color
            axisX: axisX
            axisY: axisY
        }

        Column {
            id : colLegendes
            anchors.fill: chart
            x : chart.plotArea.x
            y : chart.plotArea.y
            anchors.margins : chart.plotArea.y*2;

            Label {
                id : lbbedactual
                color:  bedactual.color
                text : "\u25A0 Bed"
                visible: opc.heatedBed
            }
            /* Not Ready
            Label {
                id : lbchamberactual
                color:  chamberactual.color
                text : "\u25A0 Chamber"
                visible: opc.heatedChamber
            }*/
            Label {
                id:lbtool0actual
                color:  tool0actual.color
                text : "\u25A0 Tool0"
            }
            Label {
                id:lbtool1actual
                color:  tool1actual.color
                text : "\u25A0 Tool1"
                visible: opc.extrudercount>1
            }
            Label {
                id:lbtool2actual
                color:  tool2actual.color
                text : "\u25A0 Tool2"
                visible: opc.extrudercount>2
            }
            Label {
                id:lbtool3actual
                color:  tool3actual.color
                text : "\u25A0 Tool3"
                visible: opc.extrudercount>3
            }
        }

    }

}
