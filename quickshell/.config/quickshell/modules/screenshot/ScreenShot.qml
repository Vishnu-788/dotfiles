import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "../../theme"

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Backend.panelVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "screenshot"

    IpcHandler {
        target: "screenshot"
        function toggle() {
            root.toggle();
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    mask: Region {
        item: Backend.panelVisible ? maskCover : null
    }

    Item {
        id: maskCover
        anchors.fill: parent
    }

    property var options: Backend.options
    property int selectedIdx: 0
    property int itemHeight: 48
    property int panelHeight: 45 + options.length * itemHeight
    property int panelWidth: 440
    readonly property color fgDim: Qt.rgba(255, 255, 255, 0.65)
    property string primaryFont: FontFamily.jetBrains
    property int primaryFontSize: FontFamily.pixelSize

    function toggle() {
        Backend.toggle();
    }

    function navigate(delta) {
        let size = options.length;
        selectedIdx = (selectedIdx + delta + size) % size;
    }

    function confirmSelection() {
        Backend.handleScreenShot(root.options[root.selectedIdx].id);
        Backend.hide();
    }

    MouseArea {
        anchors.fill: parent
        enabled: Backend.panelVisible
        onClicked: Backend.hide()
    }

    Rectangle {
        id: panel

        height: root.panelHeight
        width: root.panelWidth
        anchors.centerIn: parent

        opacity: Backend.panelVisible ? 1 : 0
        scale: Backend.panelVisible ? 1 : 0.92
        visible: opacity > 0

        focus: Backend.panelVisible

        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        color: Colors.primary
        radius: 20

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Down) {
                root.navigate(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                root.navigate(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                root.navigate((event.modifiers & Qt.ShiftModifier) || event.key === Qt.Key_Backtab ? -1 : 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.confirmSelection();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                Backend.hide();
                event.accepted = true;
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ListView {
            id: listView
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 4
            clip: true
            model: root.options

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: function (wheel) {
                    if (wheel.angleDelta.y < 0) {
                        root.navigate(1);
                    } else {
                        root.navigate(-1);
                    }
                }
            }

            delegate: Item {
                id: optionRow
                height: root.itemHeight
                width: listView.width
                required property int index
                required property var modelData

                property bool selected: root.selectedIdx === index

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: optionRow.selected ? "#1E2230" : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 12
                        }
                        spacing: 12

                        // Icon Bubble
                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignVCenter
                            radius: 9

                            Image {
                                id: appIcon
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                source: modelData.icon !== "" ? "image://icon/" + modelData.icon : ""
                                smooth: true
                                mipmap: true
                            }

                            // Fallback if no icon is provided
                            Text {
                                anchors.centerIn: parent
                                visible: appIcon.status !== Image.Ready
                                text: modelData.name.charAt(0).toUpperCase()
                                font {
                                    pixelSize: 15
                                    family: root.primaryFont
                                    weight: Font.Bold
                                }
                                color: optionRow.selected ? Colors.colFg : root.fgDim
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            elide: Text.ElideRight
                            text: modelData.name
                            font {
                                pixelSize: 13
                                family: root.primaryFont
                                weight: optionRow.selected ? Font.Medium : Font.Normal
                            }
                            color: optionRow.selected ? Colors.colFg : root.fgDim
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selectedIdx = optionRow.index
                        onClicked: {
                            root.selectedIdx = optionRow.index;
                            root.confirmSelection();
                        }
                    }
                }
            }
        }
    }
}
