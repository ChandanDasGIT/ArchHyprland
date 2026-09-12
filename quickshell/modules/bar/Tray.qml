//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets // <-- 1. IMPORT WIDGETS FOR IconImage
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu

Rectangle {
    id: trayContainer

    implicitWidth: trayRow.implicitWidth + 16
    implicitHeight: 32
    color: "#0f000000"
    radius: 8

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: trayItem
                required property var modelData
                implicitWidth: 24
                implicitHeight: 24
                color: mouseArea.containsMouse ? "#33ffffff" : "transparent"
                radius: 4

                // 2. REPLACED Image WITH IconImage FOR CRISP RENDERING
                IconImage {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: modelData.icon
                    mipmap: true // Smooths out scaling artifacts
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData.hasMenu) {
                            menuAnchor.menu = modelData.menu;
                            menuAnchor.anchor.item = trayItem;
                            menuAnchor.open();
                        }
                    }
                }
            }
        }
    }

    QsMenuAnchor {
        id: menuAnchor
        anchor.window: Quickshell.windowFor(trayContainer)
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
    }
}
