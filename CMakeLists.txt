project(octoinqml NONE)

cmake_minimum_required(VERSION 3.6)


include(GNUInstallDirs)



set(CPACK_PACKAGE_VENDOR "Thing-Printer")
set(CPACK_PACKAGE_CONTACT "FuraX49 <furax44@free.fr>")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "OctoInQML ,  OctoPrint Client in QML, another TouchScreen interface client for OctoPrint, but in EGLFS .")
set(CPACK_GENERATOR "DEB")
set(CPACK_PACKAGE_VERSION_MAJOR 0)
set(CPACK_PACKAGE_VERSION_MINOR 4)
set(CPACK_PACKAGE_VERSION_PATCH 0)
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")
set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}_${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")

Set(ALL_TARGETS "" CACHE INTERNAL "")

# ************* DEBUG ****************
set(CPACK_DEBIAN_PACKAGE_DEBUG ON)

set(DEB_DEPENDS
    "qmlscene (>= 5.11.3)"
    "qml-module-qt-labs-folderlistmodel"
    "qml-module-qt-labs-settings"
    "qml-module-qt3d"
    "qml-module-qtcharts"
    "qml-module-qtdatavisualization"
    "qml-module-qtgraphicaleffects"
    "qml-module-qtqml-models2"
    "qml-module-qtquick-controls2"
    "qml-module-qtquick-layouts"
    "qml-module-qtquick-templates2"
    "qml-module-qtquick-virtualkeyboard"
    "qml-module-qtquick-window2"
    "qml-module-qtquick-xmllistmodel"
    "qml-module-qtquick2"
    "qml-module-qtwayland-compositor"
    "qml-module-qtwebsockets"
    "qtvirtualkeyboard-plugin"
)

string(REPLACE ";" "," DEB_DEPENDS "${DEB_DEPENDS}")
set(CPACK_DEBIAN_PACKAGE_PREDEPENDS ${DEB_DEPENDS})


# ************************** REMOVE PRE-COMPILED  **************************
file (GLOB_RECURSE qmlc ${PROJECT_SOURCE_DIR}/ *.qmlc)
if (qmlc)
 file(REMOVE ${qmlc})
endif()


file (GLOB_RECURSE jsc ${PROJECT_SOURCE_DIR}/ *.jsc)
if (jsc)
 file(REMOVE ${jsc})
endif()




# ************************** APPLICATION **************************
install(FILES  "OctoInQML.qml" 
    DESTINATION "/opt/octoinqml"
)

install(DIRECTORY Pages/
    DESTINATION "/opt/octoinqml/Pages"
)


install(DIRECTORY Images/
    DESTINATION "/opt/octoinqml/Images"
)

install(DIRECTORY Components/
    DESTINATION "/opt/octoinqml/Components"
)

# ************************** SCRIPTS **************************
if(EXISTS "/lib/systemd/system")
    install(FILES scripts/octoinqml.service
      DESTINATION "/lib/systemd/system"
      PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
    )
    install(FILES scripts/octoinqml
      DESTINATION "/usr/local/bin"
      PERMISSIONS OWNER_EXECUTE OWNER_READ OWNER_WRITE GROUP_EXECUTE GROUP_READ WORLD_READ
    )

endif()

# ************************** CONFIGS **************************
install(FILES configs/QtQmlViewer.conf
      DESTINATION "/etc/octoinqml/QtProject"
      PERMISSIONS OWNER_EXECUTE OWNER_READ OWNER_WRITE GROUP_EXECUTE GROUP_READ GROUP_WRITE WORLD_READ
)
install(FILES configs/qtquickcontrols2.conf
      DESTINATION "/etc/octoinqml"
      PERMISSIONS OWNER_EXECUTE OWNER_READ OWNER_WRITE GROUP_EXECUTE GROUP_READ GROUP_WRITE WORLD_READ
)

# **************************  debian control files **************************
set( CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_SOURCE_DIR}/DEBIAN/postinst;${CMAKE_CURRENT_SOURCE_DIR}/DEBIAN/prerm" )

message(STATUS "*********************************")
message(STATUS "Command to make debian package :")
message(STATUS "cpack -G DEB")
message(STATUS "*********************************")

 
include(CPack)
