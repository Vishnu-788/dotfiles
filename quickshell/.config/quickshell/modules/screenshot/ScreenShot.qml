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

    property color colBg: Colors.colBg
    property color colFg: Colors.colFg
    property color fgDim: Colors.colFgDim
    property color colBgDim: Colors.colBgDim
    property string primaryFont: FontFamily.jetBrains
    property int primaryFontSize: FontFamily.pixelSize

    property var options: Backend.options
    property int captureState: Backend.captureState
    property var fileActions: Backend.fileActions
    property int selectedIdx: 0
    property int selectedActionIdx: 0
    property int itemHeight: 48
    property int panelHeight: 45 + (getOptionsLength() + 1) * itemHeight
    property int panelWidth: 440

    readonly property bool isCapturing: Backend.isCapturing

    function toggle() {
        Backend.toggle();
    }

    function navigate(delta) {
        let size;

        if (captureState === Backend.CaptureState.Idle) {
            size = options.length;
            selectedIdx = (selectedIdx + delta + size) % size;
        } else {
            size = fileActions.length;
            selectedActionIdx = (selectedActionIdx + delta + size) % size;
        }
    }

    function capture() {
        Backend.handleScreenshot(root.options[root.selectedIdx].id);
    }

    function performAction() {
        Backend.handleAction(root.fileActions[root.selectedActionIdx].id);
    }

    function getOptionsLength() {
        return root.captureState === Backend.CaptureState.Idle ? root.options.length : root.fileActions.length;
    }

    MouseArea {
        anchors.fill: parent
        enabled: Backend.panelVisible
        onClicked: Backend.close()
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

        color: root.colBg
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
                if (root.captureState === Backend.CaptureState.Idle) {
                    root.capture();
                } else {
                    root.performAction();
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                Backend.close();
                event.accepted = true;
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle {
            id: titleBar
            width: parent.width
            height: 45
            color: "transparent"
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 16
                    rightMargin: 16
                    topMargin: 16
                }
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "Screenshots Menu"
                    color: root.colFg
                    font {
                        family: root.primaryFont
                        pixelSize: 16
                        weight: Font.Medium
                    }
                }
            }
        }

        // Options one -> For the screenshots.
        ListView {
            id: listView
            visible: root.captureState === Backend.CaptureState.Idle && !root.isCapturing
            anchors {
                top: titleBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 12
                bottomMargin: 12
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
                    color: optionRow.selected ? root.colBgDim : "transparent"
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
                }
            }
        }

        // Options 2: For the actions on the file.
        ListView {
            id: actionListView
            visible: root.captureState === Backend.CaptureState.Captured
            anchors {
                top: titleBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 12
                bottomMargin: 12
            }
            spacing: 4
            clip: true
            model: root.fileActions

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
                id: actionRow
                height: root.itemHeight
                width: actionListView.width
                required property int index
                required property var modelData

                property bool selected: root.selectedActionIdx === index

                Rectangle {
                    anchors.fill: parent
                    color: actionRow.selected ? root.colBgDim : "transparent"
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
                                id: actionIcon
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
                                visible: actionIcon.status !== Image.Ready
                                text: modelData.name.charAt(0).toUpperCase()
                                font {
                                    pixelSize: 15
                                    family: root.primaryFont
                                    weight: Font.Bold
                                }
                                color: actionRow.selected ? Colors.colFg : root.fgDim
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
                                weight: actionRow.selected ? Font.Medium : Font.Normal
                            }
                            color: actionRow.selected ? Colors.colFg : root.fgDim
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
