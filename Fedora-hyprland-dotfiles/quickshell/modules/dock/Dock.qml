// ~/.config/quickshell/modules/dock/Dock.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

PanelWindow {
    id: dockWindow

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: false

    implicitWidth: dockBackground.implicitWidth
    implicitHeight: dockBackground.implicitHeight

    Rectangle {
        id: dockBackground
        implicitWidth: dockRow.implicitWidth + 32
        implicitHeight: dockRow.implicitHeight + 24
        radius: 26
        color: "#1e1e2e"
        anchors.centerIn: parent

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: 16

            Repeater {
                model: Hyprland.toplevels

                Rectangle {
                    id: delegateRoot
                    required property var modelData
                    property bool hovered: false

                    width: 64
                    height: 64
                    radius: 16
                    color: modelData.activated ? "#45475a" : "#313244"
                    border.color: modelData.activated ? "#89b4fa" : "transparent"
                    border.width: 2

                    Behavior on color { ColorAnimation { duration: 150 } }

                    property string appId: modelData.wayland ? modelData.wayland.appId : ""

                    property var entry: {
                        if (appId) {
                            var byAppId = DesktopEntries.byId(appId) || DesktopEntries.heuristicLookup(appId);
                            if (byAppId) return byAppId;
                        }
                        return DesktopEntries.heuristicLookup(modelData.title) || null;
                    }

                    function resolveIconPath() {
                        var candidates = [];
                        if (delegateRoot.entry && delegateRoot.entry.icon) {
                            candidates.push(delegateRoot.entry.icon);
                        }
                        if (delegateRoot.appId) {
                            candidates.push(delegateRoot.appId);
                            candidates.push(delegateRoot.appId.toLowerCase());
                            if (delegateRoot.appId.indexOf(".") !== -1) {
                                var tail = delegateRoot.appId.split(".").pop();
                                candidates.push(tail);
                                candidates.push(tail.toLowerCase());
                            }
                        }
                        for (var i = 0; i < candidates.length; i++) {
                            var path = Quickshell.iconPath(candidates[i], true);
                            if (path.length > 0) return path;
                        }
                        return Quickshell.iconPath("image-missing");
                    }

                    IconImage {
                        anchors.centerIn: parent
                        width: 38
                        height: 38
                        source: delegateRoot.resolveIconPath()
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: delegateRoot.hovered = true
                        onExited: delegateRoot.hovered = false
                        onClicked: {
                            var addr = "0x" + modelData.address;
                            if (Hyprland.usingLua) {
                                Hyprland.dispatch(
                                    "hl.dsp.focus({ window = \"address:" + addr + "\" })"
                                );
                            } else {
                                Hyprland.dispatch("focuswindow address:" + addr);
                            }
                        }
                    }

                    PopupWindow {
                        id: previewPopup
                        visible: delegateRoot.hovered && modelData.wayland != null

                        anchor {
                            window: dockWindow
                            item: delegateRoot
                            edges: Edges.Top
                            gravity: Edges.Top
                            margins.bottom: 12
                        }

                        implicitWidth: 220
                        implicitHeight: 140

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: "#181825"
                            border.color: "#89b4fa"
                            border.width: 1
                            clip: true

                            Column {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 4

                                ScreencopyView {
                                    id: preview
                                    width: parent.width
                                    height: parent.height - titleLabel.implicitHeight - 4
                                    captureSource: delegateRoot.hovered ? modelData.wayland : null
                                    live: delegateRoot.hovered
                                    paintCursor: false
                                }

                                Text {
                                    id: titleLabel
                                    width: parent.width
                                    text: modelData.title
                                    color: "#cdd6f4"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "dock"

        function toggle(): void {
            dockWindow.visible = !dockWindow.visible;
        }

        function show(): void {
            dockWindow.visible = true;
        }

        function hide(): void {
            dockWindow.visible = false;
        }
    }
}
