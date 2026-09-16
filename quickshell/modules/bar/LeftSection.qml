import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris

RowLayout {
    id: root
    spacing: 8
    height: 24
    Layout.alignment: Qt.AlignVCenter

    readonly property string nerdFontFamily: "JetBrainsMono Nerd Font"

    // ---- shared quiet hover bubble, same look as the right side bar ----
    component HoverTip: PopupWindow {
        id: tip
        property Item anchorItem: null
        property string tipText: ""

        anchor.item: anchorItem
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        anchor.rect.x: 0
        anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0
        implicitWidth: tipLabel.implicitWidth + 20
        implicitHeight: tipLabel.implicitHeight + 12
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: "#cc1a1a1a"
            border.color: "#22ffffff"
            border.width: 1

            Text {
                id: tipLabel
                anchors.centerIn: parent
                text: tip.tipText
                color: "#ffffff"
                font.pixelSize: 11
            }
        }
    }

    // ---- Workspaces ----
    RowLayout {
        id: workspaceBar
        spacing: 4
        Layout.alignment: Qt.AlignVCenter

        property bool showWorkspaceIcons: true

        property int focusedWorkspaceId: {
            var workspaces = Hyprland.workspaces.values

            for (var i = 0; i < workspaces.length; i++) {
                if (workspaces[i].focused)
                    return workspaces[i].id
            }

            return 1
        }

        // ---- Current workspace number ----
        Text {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter

            text: workspaceBar.focusedWorkspaceId
            color: "#ffffff"

            font.family: root.nerdFontFamily
            font.bold: true
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // ---- Workspace icons + Toggle ----
        RowLayout {
            id: workspaceControls
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            // ---- Toggle ----
            Rectangle {
                id: toggleRect

                Layout.preferredWidth: 12
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignVCenter
                radius: 4

                color: toggleMouseArea.containsMouse
                ? "#33ffffff"
                : "transparent"

                Text {
                    anchors.centerIn: parent

                    text: workspaceBar.showWorkspaceIcons
                    ? "\u276e"
                    : "\u276f" // ❮ / ❯

                    color: "#ffffff"
                    font.family: root.nerdFontFamily
                    font.pixelSize: 15
                }

                MouseArea {
                    id: toggleMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        workspaceBar.showWorkspaceIcons =
                        !workspaceBar.showWorkspaceIcons
                    }
                }
            }

            // ---- Animated workspace icons ----
            Item {
                id: workspaceIconsContainer

                Layout.preferredHeight: 24
                Layout.preferredWidth: workspaceBar.showWorkspaceIcons
                ? workspaceIcons.implicitWidth
                : 0
                Layout.alignment: Qt.AlignVCenter

                clip: true

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }

                RowLayout {
                    id: workspaceIcons
                    spacing: 2
                    Layout.preferredHeight: 24

                    Repeater {
                        model: Hyprland.workspaces.values

                        Rectangle {
                            required property var modelData

                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignVCenter
                            radius: 4

                            color: modelData.focused
                            ? "#64727D"
                            : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: {
                                    var icons = {
                                        1: "",
                                        2: "",
                                        3: "",
                                        4: "",
                                        5: "",
                                        6: "",
                                        7: "",
                                        8: "",
                                        9: "",
                                        10: ""
                                    }

                                    return icons[modelData.id] || ""
                                }

                                color: "#ffffff"
                                font.pixelSize: 15
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    if (Hyprland.usingLua) {
                                        Hyprland.dispatch(
                                            "hl.dsp.focus({ workspace = " +
                                            modelData.id +
                                            " })"
                                        )
                                    } else {
                                        Hyprland.dispatch(
                                            "workspace " + modelData.id
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- Media (playerctl) ----
    Text {
        id: mediaText
        Layout.alignment: Qt.AlignVCenter

        property string playerOutput: ""

        visible: playerOutput !== ""
        text: playerOutput

        color: "#ffffff"
        font.pixelSize: 14
        elide: Text.ElideRight

        Layout.preferredWidth: Math.min(implicitWidth, 200)

        Process {
            id: playerctlProc

            command: [
                "playerctl",
                "metadata",
                "--format",
                "{{artist}} - {{title}}"
            ]

            running: true

            stdout: StdioCollector {
                onStreamFinished: {
                    var output = text.trim()

                    mediaText.playerOutput =
                    output !== ""
                    ? "󰝚  " + output
                    : ""
                }
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                playerctlProc.running = true
            }
        }
    }

    // ---- Cava-style visualizer ----
    RowLayout {
        id: mediaSection
        spacing: 6
        Layout.preferredHeight: 30
        Layout.alignment: Qt.AlignVCenter

        Text {
            id: cavaText

            Layout.preferredWidth: 10 * 10
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter

            color: "#ffffff"
            font.pixelSize: 15

            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            text: cavaOutput + " "

            property string cavaOutput: "⣀⣀⣀⣀⣀⣀⣀⣀"

            Process {
                id: cavaProc

                command: [
                    "cava",
                    "-p",
                    Quickshell.env("HOME") +
                    "/.config/cava/config_waybar"
                ]

                running: true

                stdout: SplitParser {
                    onRead: function(line) {
                        var parts = line
                        .split(";")
                        .filter(function(s) {
                            return s.length > 0
                        })

                        var glyphs = [
                            "⣀",
                            "⣀",
                            "⣀",
                            "⣤",
                            "⣤",
                            "⣶",
                            "⣶",
                            "⣿",
                            "⣿"
                        ]

                        var output = ""

                        for (var i = 0; i < Math.min(parts.length, 10); i++) {
                            var value = parseInt(parts[i])

                            if (isNaN(value))
                                value = 0

                                value = Math.max(0, Math.min(8, value))
                                output += glyphs[value]
                        }

                        while (output.length < 8)
                            output += "⣀"

                            cavaText.cavaOutput = output
                    }
                }
            }
        }
    }
}
