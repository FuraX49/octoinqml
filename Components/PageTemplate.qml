import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T
import "../Components"

T.Page {
    id: control

    property alias icon: action.icon
    property alias help: action.text

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentWidth + leftPadding + rightPadding,
                            header && header.visible ? header.implicitWidth : 0,
                            footer && footer.visible ? footer.implicitWidth : 0)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentHeight + topPadding + bottomPadding
                             + (header && header.visible ? header.implicitHeight + spacing : 0)
                             + (footer && footer.visible ? footer.implicitHeight + spacing : 0))

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

   /* background: Rectangle {
        color: control.palette.window
    }
*/
    contentData:   Action {
        id : action
       }


}
