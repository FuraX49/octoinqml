.pragma library


var temps = {
    "chamber": {
        "actual": 0.0,
        "target": 0.0
    },
    "bed": {
        "actual": 0.0,
        "target": 0.0
    },
    "tool0": {
        "actual": 0.0,
        "target": 0.0
    },
    "tool1": {
        "actual": 0.0,
        "target": 0.0
    },
    "tool2": {
        "actual": 0.0,
        "target": 0.0
    },
    "tool3": {
        "actual": 0.0,
        "target": 0.0
    }
}



var progress = {
    "completion"         : 0.0 ,//	Float 	Percentage of completion of the current print job
    "filepos"    	     : 0   ,//	Integer	Current position in the file being printed, in bytes from the beginning
    "printTime" 	     : 0   ,//	Integer	Time already spent printing, in seconds
    "printTimeLeftOrigin": 0,
    "printTimeLeft"      : 0    //	Integer	Estimate of time left to print, in seconds
};




var file =  {
    "origin" : "", // The origin of the file, local when stored in OctoPrint’s uploads folder, sdcard when stored on the printer’s SD card (if available)
    "name"   : null, // The name of the file without path. E.g. “file.gco” for a file “file.gco” located anywhere in the file system. Currently this will always fit into ASCII.
    "date"   : "", // The timestamp when this file was uploaded. Only available for local files.
    "path"   : "", // The path to the file within the location. E.g. “folder/subfolder/file.gco” for a file “file.gco” located within “folder” and “subfolder” relative to the root of the location. Currently this will always fit into ASCII.
    "display": "", // The name of the file without the path, this time potentially with non-ASCII unicode characters. E.g. “a turtle 🐢.gco” for a file “a_turtle_turtle.gco” located anywhere in the file system.
    "size"   : 0   // The size of the file in bytes. Only available for local files or sdcard files if the printer supports file sizes for sd card files.
};


var filament = {
    "volume": 0.0 ,// Volume of filament used, in cm³
    "length": 0.0  // Length of filament used, in mm
};


var job =  {
    "averagePrintTime"  : null,
    "lastPrintTime"     : null, //The print time of the last print of the file, in seconds.
    "user"              : null,
    "file"              : file, // The file that is the target of the current print job
    "estimatedPrintTime": null, //The estimated print time for the file, in seconds.
    "filament"          : []    // Information regarding the estimated filament usage of the print job
};

var currentz = {"currentZ": null}; //Current height of the Z-Axis (= current height of model) during printing from a local file

var messages = []; // Lines for the serial communication log (special messages)

var serverTime = null;

function formatMachineTimeString(seconds)
{
    if (seconds) {
        var minutes = Math.floor(seconds / 60)
        var hours = Math.floor(minutes / 60);

        var timeString = (minutes < 1) ? "~ 1 min" : "> ";

        if (hours   > 0){timeString   += (hours + "h");}
        if (minutes > 0){timeString   += ((minutes % 60) + "min");}

        return timeString;
    } else {
        return "0h0min";
    }
}


var regTemp = new RegExp(/(Send: (N\d+\s+)?M105)|(Recv:\s+(ok\s+((P|B|N)\d+\s+)*)?(B|T\d*):\d+)/);
var regSD = new RegExp(/(Send: (N\d+\s+)?M27)|(Recv: SD printing byte)|(Recv: Not SD printing)/);
var regWait = new RegExp(/Recv: (wait)|(ok)$/);

var temp1 ;
var temp2 ;




