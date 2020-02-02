import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import "../Components"
import "../Components/OctoPrintShared.js" as OPS

PageTemplate {
    id: control
    title: qsTr("About REDEEM")
    implicitHeight: 480
    implicitWidth: 800

    icon.source: "../Images/infos.svg"

    function init() {
        opc.pluginData.connect(hookRedeem);
    }

    function hookRedeem(data) {

        if (data.plugin === "redeem" ) {

            // HEATER ERROR
            if ( (data.data.type==="alarm_thermistor_error")
                    || (data.data.type==="alarm_heater_too_cold")
                    ||  (data.data.type==="alarm_heater_too_hot")
                    || (data.data.type==="alarm_heater_rising_fast")
                    || (data.data.type==="alarm_heater_falling_fast") )           {
                pluginPopup.standardButtons= Dialog.Reset | Dialog.Cancel ;
                pluginPopup.addGCode("M562");
                pluginPopup.showError("Redeem " + data.data.type ,data.data.data.message);
            }

            if  (data.data.type==="alarm_endstop_hit")  {
                pluginPopup.standardButtons= Dialog.Reset | Dialog.Cancel ;
                pluginPopup.addGCode("M562");
                pluginPopup.showError("Redeem " + data.data.type ,data.data.data.message);
            }

            if  (data.data.type==="alarm_stepper_fault")  {
                octoprintclient.alarmRedeem("Stepper fault!",message.plugin.data.data.message,TypeError.Redeem_Stepper);
            }

            if  (data.data.type==="alarm_filament_jam")  {
                pluginPopup.standardButtons=  Dialog.Cancel ;
                pluginPopup.showError("Redeem " + data.data.type ,data.data.data.message);
            }


            if  (data.data.type==="alarm_operational")  {
                console.info("Alarm REDEEM operational.");
            }

        }
    }


    Text{
        id : animtext
        text : "OctoPrint Client in QML\n FuraX49 \u24B8  \n
                AboutReddem.qml page for hook plugins message \n
            alarm_thermistor_error \t for Thermistor error! \n
alarm_filament_jam \t for Filament Jam

               "
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: ScreenParams.rc_FontBig
        verticalAlignment : Text.AlignVCenter

        NumberAnimation on y{
            from: control.height
            to: -1*animtext.height
            loops: Animation.Infinite
            duration: 5000

        }
        color: ScreenParams.colorText
    }


    ErrorPopup {
        id: pluginPopup
        standardButtons: Dialog.Ok
        property string gcode: ""
        property bool   gcodewait: false
        parent: mainpage

        function addGCode(cmd){
            gcode=cmd;
            gcodewait=true;
        }


        function resetGCode(){
            opc.post_printer_command(gcode);
            gcodewait=false;
        }

        onReset: {
            if (gcodewait) {
                resetGCode();
            }
            control.visible=false;
        }

    }




}




