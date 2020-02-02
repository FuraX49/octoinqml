import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQml 2.11
import "../Components"

Loader {
    id : pageloader
    property var dynpage : null
    property string titlepage : null
    property string iconpage : null

    function setUrl(url){
        try {
            pageloader.setSource(url,{ "visible":false})  ;
        }
        catch (error) {
            print ("Error loading QML : ")
            for (var i = 0; i < error.qmlErrors.length; i++) {
                print("lineNumber: " + error.qmlErrors[i].lineNumber)
                print("columnNumber: " + error.qmlErrors[i].columnNumber)
                print("fileName: " + error.qmlErrors[i].fileName)
                print("message: " + error.qmlErrors[i].message)
            }
        }
    }

    onLoaded: {
        // push loaded Page in StackLayout
        view.data.push(pageloader.item);

        // test if Page title exist
        if (pageloader.item.title) {
            titlepage=pageloader.item.title;
        } else {
            titlepage="Page"+(mainMenu.count).toString();
            console.error(" Misc title Page on "+ titlepage )    ;
        }
        // test if Page icon exist
        if (pageloader.item.icon.source) {
            iconpage=pageloader.item.icon.source;
        } else {
            iconpage="file:./Images/print.svg";
            console.error(" Misc icon Page on "+ titlepage )    ;
        }

        mainMenu.append({"title": titlepage, "iconSource":iconpage});
    }


}
