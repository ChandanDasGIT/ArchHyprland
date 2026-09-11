import QtQuick
import Quickshell.Hyprland

Row {
    spacing: 12

    Text {
        id: clock
        color: "#ffffff"
        font.bold: true
        font.pixelSize: 16

        function update() {
            var now = new Date();
            text = Qt.formatDateTime(now, "hh:mm AP   |   dd-MM-yyyy");
        }

        Component.onCompleted: update()

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.update()
        }
    }
}
