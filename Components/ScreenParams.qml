pragma Singleton
import QtQuick 2.0
import QtQuick.Window 2.11

Item {
    property double rc_Scale : 1.0
    property double rc_Font : 1.0
    property int  rc_ItemSpace: 6
    property int  rc_ItemHeight : 32
    property int  rc_FontTitle : 16
    property int  rc_FontBig : 14
    property int  rc_FontNormal : 12
    property int  rc_FontSmall : 10
    property bool isPortrait :  false

    property color colorText : lbStatus.color

    function rescaleApplication(width,height){
        rc_Scale = Math.round((Math.min(height, width)/480) * ( 1 + (3.877223-Screen.pixelDensity)/36));
        rc_ItemSpace =  6 * rc_Scale;
        rc_ItemHeight = 34  * rc_Scale;
        rc_FontTitle = 24 * rc_Scale;
        rc_FontBig = 16 * rc_Scale;
        rc_FontNormal = 12 * rc_Scale;
        rc_FontSmall = 10 * rc_Scale;
        isPortrait = height>width;
    }

    /* Converts logical pixels to device (physical) pixels. Generally, all absolute sizes, positions,
       margins and other distances should always be specified using this function.*/
    function dp( x ) {
        return Math.round( x * Settings.dpiScaleFactor );
    }

    /* Converts relative font size to pixels. This function should be used for specifying all font sizes,
       but it can also be useful for some sizes and distances (e.g. the height of a button can be specified as a multiple of the font size,
       provided that appropriate layouts are used). */
    function em( x ) {
        return Math.round( x * TextSingleton.font.pixelSize );
    }
}
