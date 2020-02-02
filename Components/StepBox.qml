import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3


SpinBox {
    id: control

    anchors.margins: 2
    spacing: 5
    padding: 0
    from: 0
    value: 0
    to:  items.length -1
    implicitWidth: 120
    implicitHeight: 40
    property int decimals: 1
    property var items: [0.1, 0.5, 1,5,10,50]

    textFromValue: function(value) {
        return Number(items[value]).toLocaleString(Qt.locale("us_US"), 'f', control.decimals);
    }

    valueFromText: function(text) {
        return Number.fromLocaleString(Qt.locale("us_US"), text);
    }


    background: Rectangle {
        id: rectangle
        radius: 4
        color: control.palette.shadow
        border.width: 2
        border.color:  control.palette.highlightedText
    }

}
