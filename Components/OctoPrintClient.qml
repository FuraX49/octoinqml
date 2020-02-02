import QtQuick 2.11
import QtQml 2.3
import QtWebSockets 1.1
import QtQuick.Controls 2.4
import "OctoPrintShared.js" as OPS

Item {

    id: octoprintclient

    property bool   debug: false
    property bool   humanask: false
    property string url:   'http://127.0.0.1:5000'
    property string apikey   : ''
    property string username : ''
    property string printerProfile   : ''
    property string printerPort : ''
    property int    printerbaudRate : 115200

    property bool connected : false
    property real intervalcnx: 10 //0
    property int retrycpt : 0



    property string stateText : 'Closed';
    property bool stateOperational: false
    property bool statePaused : false
    property bool statePrinting : false
    property bool stateCancelling: false
    property bool statePausing : false
    property bool stateSdReady: false
    property bool stateError: false
    property bool stateReady: false
    property bool stateClosedOrError: false
    property bool stateFileSelected: false

    property bool sdSupport: false
    property bool heatedBed: false
    property bool heatedChamber: false
    property int extrudercount: -1
    property real volumeWidth : 0
    property real volumeHeight  : 0
    property real volumeDepth : 0
    property string volumeOrigin : "lowerleft"
    property string volumeformFactor : "rectangular"


    signal tryConnect(int cnttry)
    signal showError(string titlerr,string msgerr)
    signal logChanged(string log)
    signal tempChanged(bool history, date heure)
    signal jobChanged()
    signal progressChanged()
    signal positionUpdate(real x, real y , real z)
    signal currentZChanged(real z)
    signal pluginData(var data )

    property alias filesmodel: filesmodel
    property alias actionsmodel: actionsmodel
    property alias baudratemodel : baudratemodel
    property alias profilesmodel : profilesmodel
    property alias cnxtimer : cnxtimer

    QtObject {
        id: req
        property var params;
    }

    ListModel {
        id : filesmodel
    }

    ListModel {
        id : actionsmodel
    }

    ListModel {
        id : baudratemodel
    }

    ListModel {
        id : profilesmodel
    }

    function init() {
        retrycpt=0;
        cnxtimer.start();
    }

    function sendRequest(method,api,callback ){
        var xhr = new XMLHttpRequest;
        var cmdurl= url+api;
        xhr.onreadystatechange = (function(myxhr) {
            return function() {
                if(myxhr.readyState === XMLHttpRequest.DONE)
                {
                    if (debug) {
                        console.debug("XMLHttpRequest.readyState : " +myxhr.readyState);
                        console.debug("XMLHttpRequest.statusText : " +myxhr.statusText);
                        console.debug("XMLHttpRequest.status : " +myxhr.status);
                        console.debug("XMLHttpRequest.responseText : " +myxhr.responseText);
                    }
                    callback(myxhr);
                }
            }
        })(xhr);
        xhr.open(method,cmdurl,false);
        xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
        xhr.setRequestHeader('X-Api-Key',apikey);
        xhr.setRequestHeader('Content-Lenght',String(req.params).length);
        if (debug){
            console.debug('OctoPintClient url :',cmdurl);
            console.debug('OctoPintClient POST:',req.params);
            console.debug('OctoPintClient Length :' ,String(req.params).length);
        }
        xhr.send(req.params);
    }

    /*
    Retrieve the current connection status,
    if not connected  : connect with profile settings
    if connected with same profile settings :  only connect
    else error
     */
    function  get_connection(){
        if (connected) return;
        req.params='';
        sendRequest('GET','/api/connection',
                    function (g) {
                        if (!g.status === 200)
                        {
                            console.log(" error get connection status ! " );
                        } else {
                            try {
                                var jsonrep =JSON.parse(g.responseText);
                                if (jsonrep.current.state==="Closed" ) {
                                    post_connection(true);
                                } else if (jsonrep.current.printerProfile===printerProfile ) {
                                    post_connection(false);
                                } else  {
                                    cnxtimer.stop();
                                    showError("ERROR CONNECTION ","Octoprint already connected to a printer !");
                                }
                            }
                            finally {
                                if (retrycpt<1)  console.log(" error /api/connection , no html reponse ! " );
                            }
                        }
                    }
                    ) ;
    }


    function  post_connection(profile){
        if (connected) return;
        if (profile) {
            req.params=' { "command": "connect" , "printerProfile": "'+printerProfile +'", "baudrate": '+printerbaudRate +', "port": "'+printerPort+'" }';
            sendRequest('POST','/api/connection',
                        function (p) {
                            if (p.status === 204)
                            {
                                opws.ws_connect();
                            } else  {
                                console.log("Error connecting " +p.responseText);
                                connected=false;
                            }
                        }
                        ) ;
        } else {
            opws.ws_connect();
        }
    }


    function  disconnect(){
        if (!connected) return;
        req.params=' { "command": "disconnect" }';
        humanask=true;
        sendRequest('POST','/api/connection',
                    function (p) {
                        if (p.status === 204)
                        {
                            opws.ws_disconnect();
                            cnxtimer.stop();
                        }
                    }
                    ) ;
    }



    function  get_settings(){
        if (!connected) return;
        req.params='';
        sendRequest('GET','/api/settings',
                    function (g) {
                        var jsonrep =JSON.parse(g.responseText);

                        if (jsonrep.feature.sdSupport) {
                            sdSupport =jsonrep.feature.sdSupport;
                        }

                        var regfilters = jsonrep.terminalFilters;
                        for (var i in regfilters) {
                            if (regfilters[i].name===mainpage.cfg_RegExpTemp) {
                                OPS.regTemp=new RegExp(regfilters[i].regex,'g')
                            }
                            if (regfilters[i].name===mainpage.cfg_RegExpSD) {
                                OPS.regSD=new RegExp(regfilters[i].regex,'g')
                            }
                            if (regfilters[i].name===mainpage.cfg_RegExpWait) {
                                OPS.regWait=new RegExp(regfilters[i].regex,'g')
                            }
                        }
                        var profiles = jsonrep.temperature.profiles;
                        for ( i in profiles) {
                            if (profiles[i].name===cfg_TempName1) {
                                OPS.temp1=profiles[i];
                            }
                            if (profiles[i].name===cfg_TempName2) {
                                OPS.temp2=profiles[i];
                            }
                        }

                        if (!g.status === 200)
                        {
                            console.log(" error get OctoPrint settings... " );
                        }
                    }
                    ) ;
    }


    function  get_job() {
        if (debug) console.debug("Job info");
        req.params = '{}'  ;
        sendRequest('GET','/api/job',
                    function (g) {
                        if (g.status !== 200)
                        {
                            console.log(" error job info  :" +g.responseText);
                        }
                    }
                    ) ;
    }

    function  post_job_command(command) {
        command=command.toLowerCase();
        if (debug) console.debug("Job "+command);
        req.params = ' { "command": '+command+' } '  ;
        sendRequest('POST','/api/job',
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error jobcommand  :" +p.responseText);
                        }
                    }
                    ) ;
    }



    function  get_printer_states(){
        if (!connected) return;
        req.params='';
        sendRequest('GET',' /api/printer?exclude=temperature,sd',
                    function (g) {
                        if (g.status !== 200)
                        {
                            console.log(" error job info  :" +g.responseText);
                        }
                    }
                    ) ;
    }


    function  get_printerprofiles(){
        if (!connected) return;
        req.params='';
        sendRequest('GET','/api/printerprofiles',
                    function (g) {
                        var jsonrep =JSON.parse(g.responseText);
                        var profiles = jsonrep.profiles;
                        for (var i in profiles) {
                            if (profiles[i].id===printerProfile) {
                                heatedBed=profiles[i].heatedBed;
                                heatedChamber=profiles[i].heatedChamber;
                                volumeformFactor=profiles[i].volume.formFactor;
                                volumeWidth=profiles[i].volume.width;
                                volumeHeight=profiles[i].volume.height;
                                volumeDepth=profiles[i].volume.depth;
                                volumeOrigin=profiles[i].volume.origin;
                                // must be in last ! for update view pages
                                extrudercount=profiles[i].extruder.count;
                            }
                        }

                        if (!g.status === 200)
                        {
                            console.log(" error get list Printer profiles " );
                        }
                    }
                    ) ;
    }

    // ******************** PRINT FUNCTIONS *********************************

    function  post_tool_target( tool,target){
        if (!connected) return;
        tool=tool.toLowerCase().trim();
        req.params = ' { "command": "target" ,  "targets": { "' + tool +'":'+  target + '}}'  ;
        sendRequest('POST','/api/printer/tool',
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error target cmd" +p.responseText);
                        }
                    }
                    ) ;
    }

    function  post_bed_target(target){
        if (!connected) return;
        req.params = ' { "command": "target" ,  "target": '+  target + '}'  ;
        sendRequest('POST','/api/printer/bed',
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error bed target cmd" +p.responseText);
                        }
                    }
                    ) ;
    }

    function  post_chamber_target(target){
        if (!connected) return;
        req.params = ' { "command": "target" ,  "target": '+  target + '}'  ;
        sendRequest('POST','/api/printer/chamber',
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error chamber target cmd" +p.responseText);
                        }
                    }
                    ) ;
    }


    // ******************** FILES FUNCTIONS *********************************
    function  get_files(location,path){
        if (!connected) return;
        var api = '/api/files';
        req.params = ' { "command": "files" ,  "recursive":"false"}'  ;
        if (typeof location === "undefined") {
            location='local';
        }
        api=api.concat('/',location)
        if ((typeof path !== "undefined") && (path !== ""))  {
            api=api.concat('/',path)
        }
        sendRequest('GET',api,
                    function (p) {
                        if (p.status === 200)
                        {
                            var jsonrep =JSON.parse(p.responseText);
                            filesmodel.clear();
                            var files =jsonrep.files;
                            for (var i in files ) {
                                filesmodel.append(files[i]);
                            }
                            var childrens =jsonrep.children;
                            if (typeof childrens !== "undefined") {
                                for (var  j in childrens ) {
                                    filesmodel.append(childrens[j]);
                                }
                                OPS.file.type="folder";
                                OPS.file.path=path.substr(0,path.lastIndexOf('/'));
                                OPS.file.display=".. Back to /"+OPS.file.path;
                                filesmodel.insert(0,OPS.file);
                            }
                        } else {
                            console.log(" error getfilespath  :" +p.responseText);
                        }
                    }
                    ) ;
    }

    function  post_files_select(origin,path){
        if (!connected) return;
        req.params = ' { "command" : "select" }'  ;
        var api = '/api/files';
        api=api.concat('/',origin,'/',path);
        sendRequest('POST',api,
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error fileselect  :" +p.responseText);
                            showError("Error file",p.responseText);
                        }
                    }
                    ) ;
    }


    // ******************** JOG FUNCTIONS *********************************

    function  post_printhead_jog( axe,valeur){
        if (!connected) return;
        axe= axe.toUpperCase();
        req.params = ' { "command": "jog" ';
        req.params=req.params.concat( ' , "x":');
        req.params=req.params.concat((axe==="X")? valeur: 0) ;
        req.params=req.params.concat( ' , "y":');
        req.params=req.params.concat((axe==="Y")? valeur: 0) ;
        req.params=req.params.concat( ', "z":');
        req.params=req.params.concat((axe==="Z")? valeur: 0) ;
        req.params=req.params.concat('}');
        sendRequest('POST','/api/printer/printhead',
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error jog cmd" + p.responseText);
                        }
                    }
                    ) ;
    }


    function  post_printhead_home(axe){
        if (!connected) return;
        axe= axe.toLowerCase();
        req.params = ' { "command": "home"  , "axes": [' + axe + '] }';
        sendRequest('POST','/api/printer/printhead',
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error home cmd" +p.responseText);
                        }
                    }
                    ) ;
    }


    function  post_printer_command(command){
        if (!connected) return;
        req.params = ' { "command": "'+  command + '"}'  ;
        sendRequest('POST','/api/printer/command',
                    function (p) {
                        if ((p.status !== 204) )
                        {
                            console.log(" error sendcommand  :"  +command);
                            console.log(" result sendcommand  :"  +p.responseText);
                        }
                    }
                    ) ;
    }

    function  post_printer_tool_select(tool){
        if (!connected) return;
        tool=tool.toLowerCase();
        req.params = ' { "command": "select" ,  "tool": "tool'+  tool + '"}'  ;
        sendRequest('POST','/api/printer/tool',
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error select tool cmd" +p.responseText);
                        }
                    }
                    ) ;
    }

    function  post_printer_tool_extrude(amount){
        if (!connected) return;
        req.params = ' { "command": "extrude" ,  "amount": '+  amount + '}'  ;
        sendRequest('POST','/api/printer/tool',
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error extrude cmd :" +p.responseText);
                        }
                    }
                    ) ;
    }

    // ******************** DIVERS FUNCTIONS *********************************
    function  get_system_commands(){
        if (!connected) return;
        req.params = '';
        sendRequest('GET','/api/system/commands',
                    function (g) {
                        actionsmodel.clear();
                        var jsonrep =JSON.parse(g.responseText);
                        for (var source in jsonrep) {
                            var jsonActions = jsonrep[source];
                            for (var i in jsonActions ) {
                                actionsmodel.append(jsonActions[i]);
                            }
                        }
                        if (g.status !== 200)
                        {
                            console.log(" error get actions list  :" +p.responseText);
                        }
                    }
                    ) ;
    }
    function  post_system_commands(source,action){
        if (!connected) return;
        req.params = ''  ;
        var api = '/api/system/commands';
        api=api.concat('/',source,'/',action);
        sendRequest('POST',api,
                    function (p) {
                        if (p.status !== 204)
                        {
                            console.log(" error exec system command " +p.responseText);
                        }
                    }
                    ) ;
    }
    /*============================================================================================= */
    OctoPrintWS {
        id : opws
    }


    Timer {
        id : cnxtimer
        interval:1000*intervalcnx
        running : false
        repeat : true
        triggeredOnStart: true

        onTriggered: {
            retrycpt++;
            if (retrycpt<10)  {
                if (debug) console.debug('cnxtimer connect profile try :' +retrycpt);
                tryConnect(retrycpt);
                get_connection();
            } else {
                showError("ERROR Configuration","Review your configuration, timout when try connecting !");
                stop();
            }
        }
    }




}
