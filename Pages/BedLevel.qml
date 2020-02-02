import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtDataVisualization 1.2
import QtQml 2.3

import "../Components"
import "../Components/OctoPrintShared.js" as OPS



PageTemplate {
    id: bedlevelpage
    title : "Bed Level"
    icon.source: "../Images/bedlevel.svg"
    x:0
    y:0
    width: 800
    height: 480


    property real bedwidth : 200
    property real beddepht : 200
    property bool bedformSquare: true
    property real minprob  : -1.0
    property real maxprob  : 1.0

    function init() {
        bedwidth = opc.volumeWidth;
        beddepht = opc.volumeDepth;
        bedformSquare = (opc.volumeformFactor==="rectangular");
        opc.pluginData.connect(hookRedeem);
    }

    function hookRedeem(data) {

        console.debug("hookRedeem BED");

        if (data.plugin === "redeem" ) {
            if (data.data.type==="bed_probe_point") {
                //bedprobepoint(message.plugin.data.data.message[0],message.plugin.data.data.message[1],message.plugin.data.data.message[2]);

                OPS.ProbeMatrix.push({ mx : parseFloat(message.plugin.data.data.message[0]) ,
                                         my : parseFloat(message.plugin.data.data.message[1]) ,
                                         mz : parseFloat(message.plugin.data.data.message[2]) });
                console.debug("bed_probe_point");
            }

            if (data.data.type==="bed_probe_reset") {

                OPS.ProbeMatrix=[];
                //bedProbeReset();
            }

        }
    }

    function drawMatrix(){
        //matrixData.clear();
        if (OPS.ProbeMatrix.length >0) {
            minprob  = +100.0;
            maxprob  = -100.0;
            for (var i = 0; i < OPS.ProbeMatrix.length; i++) {
                matrixData.append({"mx": OPS.ProbeMatrix[i].X, "my": OPS.ProbeMatrix[i].Y, "mz" : OPS.ProbeMatrix[i].Z});
                if(OPS.ProbeMatrix[i].Z> maxprob) maxprob =OPS.ProbeMatrix[i].Z;
                if(OPS.ProbeMatrix[i].Z< minprob) minprob =OPS.ProbeMatrix[i].Z;
            }
            var diff = Math.min(Math.abs(maxprob - minprob),0.5);
            var  incgradient = Math.min(0.5-diff ,0.4999);
            yAxis.segmentCount=diff / 0.01;
            mingradient.position=0.5-incgradient;
            maxgradient.position=0.5+incgradient;
            yAxis.min =  minprob  ;
            yAxis.max = maxprob  ;
            surfaceGraph.update();
            console.info("gradient / diff :" +incgradient+" / "+diff);
        }  else {
            errorPopup.showError("BED MATRIX","You must run G29 macro before display")
        }
    }

    ListModel {
        id: matrixData
        ListElement{  mx: 025; my: 025; mz: -0.05; }
        ListElement{  mx: 025; my: 100; mz: -0.03; }
        ListElement{  mx: 025; my: 175; mz: -0.01; }

        ListElement{  mx: 150; my: 025; mz: 0.0; }
        ListElement{  mx: 150; my: 100; mz: 0.01; }
        ListElement{  mx: 150; my: 175; mz: 0.02; }

        ListElement{  mx: 275; my: 025; mz: 0.01; }
        ListElement{  mx: 275; my: 100; mz: 0.05; }
        ListElement{  mx: 275; my: 175; mz: 0.01; }
    }




    Rectangle {
        id: rectangle

        anchors.fill: parent
        anchors.margins: 0
        color: bedlevelpage.palette.window


        Item {
            id: surfaceView
            anchors.fill: parent

            ColorGradient {
                id: surfaceGradient
                ColorGradientStop { id: mingradient; position: 0.00; color: "blue" }
                ColorGradientStop { id: midgradient; position: 0.50; color: "green" }
                ColorGradientStop { id :maxgradient; position: 1.00; color: "red" }
            }

            ValueAxis3D {
                id: xAxis
                labelFormat: "%i mm"
                title: "X Width"
                min : 0
                max : bedwidth
                segmentCount: (bedwidth /50)
                titleVisible: true
                titleFixed: false
            }


            ValueAxis3D {
                id: zAxis
                labelFormat: "%i mm"
                title: "Y Depth"
                min : 0
                max : beddepht
                segmentCount: (beddepht/50)
                titleVisible: true
                titleFixed: false
            }

            ValueAxis3D {
                id: yAxis
                labelFormat: "%.3f"
                title: "Z Offset"
                titleVisible: true
                labelAutoRotation: 0
                segmentCount: 10
                titleFixed: false
            }

            Theme3D {
                id : ebony
                type:  Theme3D.ThemeEbony
                font.pixelSize: ScreenParams.rc_FontNormal
                singleHighlightColor : "white"
            }

            Theme3D {
                id : digia
                type:  Theme3D.ThemeDigia
                font.pixelSize: ScreenParams.rc_FontNormal

            }



            Camera3D {
                id : cam3ds
                cameraPreset: Camera3D.CameraPresetFrontHigh
                minZoomLevel:50
                onZoomLevelChanged: {
                    zoomSlider.value=zoomLevel;
                }
            }



            Surface3D {
                id: surfaceGraph
                visible : true
                width: surfaceView.width
                height: surfaceView.height
                polar:  bedformSquare ? false: true
                flipHorizontalGrid: false

                horizontalAspectRatio: 0.0
                //aspectRatio: 2.0
                selectionMode: AbstractGraph3D.SelectionItem
                shadowQuality: shadowsSupported? AbstractGraph3D.ShadowQualityMedium :AbstractGraph3D.ShadowQualityNone
                scene.activeCamera : cam3ds

                theme:  isDarkTheme?ebony:digia
                axisX: xAxis
                axisY: yAxis
                axisZ: zAxis

                Surface3DSeries {
                    id: surfaceSeries
                    name: "BedMatrix"
                    drawMode: Surface3DSeries.DrawSurfaceAndWireframe // DrawSurfaceAndWireframe // DrawSurface
                    baseGradient: surfaceGradient
                    colorStyle: Theme3D.ColorStyleRangeGradient// ColorStyleObjectGradient // ColorStyleRangeGradient
                    flatShadingEnabled : false
                    itemLabelFormat: " Offset : @yLabel (X:@xLabel Y:@zLabel)"
                    itemLabelVisible : true
                    ItemModelSurfaceDataProxy {
                        itemModel:  matrixData
                        rowRole: "mx"
                        columnRole: "my"
                        xPosRole: "mx"
                        zPosRole: "my"
                        yPosRole: "mz"
                    }
                }
            }

        }

        RowLayout {
            id: buttonLayout
            Layout.minimumHeight: ScreenParams.rc_ItemHeight *1.5
            anchors.margins: ScreenParams.rc_ItemSpace
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            spacing: ScreenParams.rc_ItemSpace


            Slider {
                id: zoomSlider
                Layout.fillHeight: true
                Layout.fillWidth: true
                from: 100
                to: 0.1
                value: 40.0
                onValueChanged: {
                    cam3ds.zoomLevel=value;
                }
            }
            Button {
                id: btnRedraw
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: "Redraw"
                highlighted: true
                onClicked: {
                    drawMatrix();
                }
            }

            Button {
                id: btnLevel
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: "G29"
                highlighted: true
                onClicked: {
                    opc.sendcommand("G29");
                }
            }
        }

        Component.onCompleted: {
            zoomSlider.to= surfaceGraph.scene.activeCamera.maxZoomLevel;
            zoomSlider.from =surfaceGraph.scene.activeCamera.minZoomLevel;
            zoomSlider.value=surfaceGraph.scene.activeCamera.zoomLevel;
        }

    }

 }


