//pragma Singleton
import QtQuick 2.11
import QtQml 2.3
import QtWebSockets 1.1
import "OctoPrintShared.js" as OPS

/*============================================================================================= */
WebSocket {
    id: wsocket
    property var statusNames: ({})
    property int advisedTimeout: 30000



    function ws_connect(){
        active=false; active=true; // toggle status to force reconnect if URL doesn't change
        var socketURL = octoprintclient.url.replace( /^(?:\w+:\/\/)/, 'ws://' );
        url = socketURL+'/sockjs/websocket';
    }

    function ws_disconnect(){
        active=false;
        cnxtimer.stop();
    }


    onTextMessageReceived: {
        if (debug) console.log('WebSocket recv:',message);
        if ("string"===typeof message) message=JSON.parse(message);

        // =========================== CONNECTED PAYLOAD ===========================
        if (message.connected) {
            octoprintclient.connected=true;
            octoprintclient.cnxtimer.stop();
            var msg = '{ "auth" : "' + username + ':' + apikey  + '" }'
            if (debug) console.debug('WebSocket receive connected  and send : ' + msg);
            wsocket.sendTextMessage(msg);
            return ;
        }

        var temps = null;
        var t = null;
        var now = null;
        var logs = null;

        // =========================== PLUGIN MESSAGE ===========================

        if (message.plugin)  {
            octoprintclient.pluginData(message.plugin);
        }

        // =========================== HISTORY PAYLOAD ===========================
        if (message.history)  {

            if (message.history.logs) {
                logs =message.history.logs ;
                for ( t in logs ) {
                    octoprintclient.logChanged(logs[t]);
                }
            }

            if (message.history.temps)  {
                temps =message.history.temps ;
                for ( t in temps ) {
                    now = new Date(temps[t].time*1000);

                    if (heatedChamber && temps[t].chamber) {
                        OPS.temps.chamber.actual = temps[t].chamber.actual;
                        OPS.temps.chamber.target = temps[t].chamber.target;
                    }

                    if (temps[t].bed) {
                        OPS.temps.bed.actual = temps[t].bed.actual;
                        OPS.temps.bed.target = temps[t].bed.target;
                    }

                    if (temps[t].tool0) {
                        OPS.temps.tool0.actual = temps[t].tool0.actual;
                        OPS.temps.tool0.target = temps[t].tool0.target;
                    }

                    if (temps[t].tool1) {
                        OPS.temps.tool1.actual = temps[t].tool1.actual;
                        OPS.temps.tool1.target = temps[t].tool1.target;
                    }
                    if (temps[t].tool2) {
                        OPS.temps.tool2.actual = temps[t].tool2.actual;
                        OPS.temps.tool2.target = temps[t].tool2.target;
                    }
                    if (temps[t].tool3) {
                        OPS.temps.tool3.actual = temps[t].tool3.actual;
                        OPS.temps.tool3.target = temps[t].tool3.target;
                    }
                    octoprintclient.tempChanged(true,now);
                }

            }
            temps=null;
        }

        // =========================== CURRENT PAYLOAD ===========================
        if (message.current) {
            if (debug) console.debug('message current !');

            if (message.current.temps)  {
                temps =message.current.temps ;
                for ( t in temps ) {
                    now = new Date(temps[t].time);

                    if (temps[t].bed) {
                        OPS.temps.bed.actual = temps[t].bed.actual;
                        OPS.temps.bed.target = temps[t].bed.target;
                    }
                    /* Not Ready
                    if (heatedChamber && temps[t].chamber) {
                        OPS.chamber.actual = temps[t].chamber.actual;
                        OPS.chamber.target = temps[t].chamber.target;
                    } */

                    if (temps[t].tool0) {
                        OPS.temps.tool0.actual = temps[t].tool0.actual;
                        OPS.temps.tool0.target = temps[t].tool0.target;
                    }

                    if (temps[t].tool1) {
                        OPS.temps.tool1.actual = temps[t].tool1.actual;
                        OPS.temps.tool1.target = temps[t].tool1.target;
                    }
                    if (temps[t].tool2) {
                        OPS.temps.tool2.actual = temps[t].tool2.actual;
                        OPS.temps.tool2.target = temps[t].tool2.target;
                    }
                    if (temps[t].tool3) {
                        OPS.temps.tool3.actual = temps[t].tool3.actual;
                        OPS.temps.tool3.target = temps[t].tool3.target;
                    }
                    octoprintclient.tempChanged(false,now);
                }
            }


            if (message.current.logs) {
                logs =message.current.logs ;
                for (t in logs ) {
                    octoprintclient.logChanged(logs[t]);
                }
            }


            if (message.current.state) {
                octoprintclient.stateText        = message.current.state.text;
                octoprintclient.stateOperational =  message.current.state.flags.operational;
                octoprintclient.statePaused =  message.current.state.flags.paused;
                octoprintclient.statePrinting =  message.current.state.flags.printing;
                octoprintclient.stateCancelling=  message.current.state.flags.cancelling;
                octoprintclient.statePausing =  message.current.state.flags.pausing;
                octoprintclient.stateSdReady=  message.current.state.flags.sdReady;
                octoprintclient.stateError=  message.current.state.flags.error;
                octoprintclient.stateReady=  message.current.state.flags.ready;
                octoprintclient.stateClosedOrError=  message.current.state.flags.closedOrError;
            }

            if (message.current.job) {
                OPS.job=message.current.job;
                if (OPS.job.file.path) octoprintclient.stateFileSelected=true;
                octoprintclient.jobChanged();
            }

            if (message.current.progress) {
                OPS.progress=message.current.progress;
                octoprintclient.progressChanged();
            }

            if (message.current.messages) {
                OPS.messages=message.current.messages;
            }

            if (message.current.serverTime) {
                OPS.serverTime = new Date(message.current.serverTime*1000);
            }

        }

        // =========================== EVENT PAYLOAD ===========================
        if (message.event) {
            if (message.event.type==='FileSelected') {
                octoprintclient.stateFileSelected=true;

            } else if (message.event.type==='PositionUpdate') {
                positionUpdate(message.event.payload.x,message.event.payload.y,message.event.payload.z)


            } else if (message.event.type==='ZChange') {
                currentZChanged(message.event.payload.new);

            } else if (message.event.type==='Home') {
                //sendcommand("M114");
                console.debug("****** HOME **********");
                console.debug(message);

            } else if (message.event.type==='ClientOpened') {
                logChanged("Client opened from remote address "+ message.event.payload.remoteAddress);


            } else if (message.event.type==='PrintResumed') {
                octoprintclient.statePrinting=true;
                octoprintclient.statePaused =false;

            } else if (message.event.type==='PrintCancelled') {
                octoprintclient.statePrinting=true;
                octoprintclient.statePaused =false;

            } else if (message.event.type==='ClientClosed') {
                octoprintclient.logChanged("Client closed from remote address "+ message.event.payload.remoteAddress);

            } else if (message.event.type==='Disconnected') {
                console.log("Client Disconnected " );


            } else if (message.event.type==='PrinterStateChanged') {
                switch (message.event.payload.state_id) {

                case "PRINTING":
                    octoprintclient.statePrinting=true;
                    octoprintclient.stateReady=false;
                    break;

                case "STARTING":
                    break;

                case "OPERATIONAL":
                    octoprintclient.statePrinting=false;
                    break;

                case "PAUSED":
                    octoprintclient.statePaused=true;
                    octoprintclient.statePrinting=false;
                    break;


                case "CANCELLING":
                    octoprintclient.stateCancelling=true;
                    break;


                case "PAUSING":
                    octoprintclient.statePausing=true;
                    break;

                case "RESUMING":
                    octoprintclient.statePaused=false;
                    octoprintclient.statePrinting=true;
                    octoprintclient.stateReady=false;
                    break;

                case "FINISHING":
                    break;


                case "OFFLINE":
                    disconnect();
                    octoprintclient.stateText="OFFLINE";
                    octoprintclient.stateReady=false;
                    break;
                }

            } else if (message.event.type==='Disconnecting') {
                // Client Disconnecting
            } else if (message.event.type==='Connecting') {
                // Client connecting
            } else if (message.event.type==='Connected') {
                // Client connect
            } else if (message.event.type==='ToolChange') {
                // tool changed
            } else if (message.event.type==='FirmwareData') {
                // M115 asked
            } else if (message.event.type==='UpdatedFiles') {
                // M20 ?

            } else {
                if (debug) {
                    console.debug(" ==== EVENT PAYLOAD =>  " +message.event.type );
                }
            }
        }

    }

    onStatusChanged: {
        if (!wsocket) return debug && console.debug('OctoPrintClient has been deleted');
        if (debug) console.debug('OPC WebSocket status:',statusNames[wsocket.status]);
        switch(wsocket.status){
        case WebSocket.Open:
            if (debug) console.debug(' WebSocket.open ');
            octoprintclient.humanask=false;
            break;

        case WebSocket.Error:
            console.log('OPC WebSocket error : ', wsocket.errorString);
            octoprintclient.stateClosedOrError=true;
            break;

        case WebSocket.Closed:
            if (debug) console.debug('OPC attempting to reconnect...');
            octoprintclient.connected=false;
            active=false;
            if (!octoprintclient.humanask) {
                console.debug('OPC attempting to reconnect...');
                octoprintclient.retrycpt=0;
                octoprintclient.cnxtimer.start();
                break;
            }
        }
    }


    Component.onCompleted: {
        statusNames[WebSocket.Connecting] = 'WebSocket.Connecting';
        statusNames[WebSocket.Open]       = 'WebSocket.Open';
        statusNames[WebSocket.Closing]    = 'WebSocket.Closing';
        statusNames[WebSocket.Closed]     = 'WebSocket.Closed';
        statusNames[WebSocket.Error]      = 'WebSocket.Error';
    }


}
