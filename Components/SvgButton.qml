import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T





T.ToolButton {
    id: control
    property bool homebutton: false
    autoRepeat : homebutton ?  false : true
    autoRepeatDelay : 500
    autoRepeatInterval : 500

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: 6
    spacing: 6

    icon.width: 120
    icon.height: 120
    icon.color : visualFocus ? control.palette.link  :  ScreenParams.colorText

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        Text {
            z : 99
            text: control.text
            font: control.font
            color: visualFocus ?   ScreenParams.colorText :control.palette.link
            anchors.centerIn: parent
        }

    }

    background: Rectangle {
        implicitWidth: 128
        implicitHeight: 128
        opacity: control.down ? 1.0 : 0.5
        color: control.down || control.checked || control.highlighted ? control.palette.mid : control.palette.button
    }
}

/*

T.Button {
    id: control
    property bool homebutton: false
    autoRepeat : homebutton ?  false : true
    autoRepeatDelay : 500
    autoRepeatInterval : 500
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: 2
    leftPadding: padding + 2
    rightPadding: padding + 2
    spacing: 2


    icon.width: control.height - 4
    icon.height: control.height - 4

    icon.color: visualFocus ? control.palette.highlightedText : control.palette.windowText

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        anchors.centerIn: background

        color: control.visualFocus ? control.palette.highlight : control.palette.buttonText
    }

    background: Rectangle {
        implicitWidth: 32
        implicitHeight: 32
        x :0
        y : 0
        visible: !control.flat || control.down || control.checked || control.highlighted
        opacity: control.down ? 1.0 : 0.5
        color: control.down || control.checked || control.highlighted ? control.palette.mid : control.palette.button
        border.color: control.palette.highlight
        border.width: control.visualFocus ? 2 : 0
    }
}


*/
