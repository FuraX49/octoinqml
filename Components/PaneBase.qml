import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T

T.Pane {
    id: control

    padding: 2

    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0, contentHeight + topPadding + bottomPadding)

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)
    property int borderWidth: 2


    background: Rectangle {
        id: rectangle
        radius: 4
        color: control.palette.shadow
        border.width: borderWidth
        border.color:  control.palette.highlightedText
    }
}
