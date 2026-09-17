pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"

PanelWindow {
    id: panel

    visible: false
    implicitWidth: 340
    implicitHeight: 460
    IpcHandler {
        target: "wifi"

        function toggle(): void {
            panel.toggle();
        }
        function open(): void {
            panel.open();
        }
        function close(): void {
            panel.close();
        }
    }

    // Transparent root to allow the inner rectangle to handle rounded corners
    color: "transparent"

    anchors {
        top: false
        right: false
        left: false
        bottom: false
    }

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property alias service: wifiService
    property string selectedSsid: ""
    property bool passwdRequired: false

    // Theme
    property color colBg: Colors.colBg
    property color colFg: Colors.colFg
    property color colBgDim: Colors.colBgDim
    property color colFgDim: Colors.colFgDim
    property color accentFill: Colors.accentFill
    property string primaryFont: FontFamily.jetBrains

    WifiService {
        id: wifiService
    }

    function toggle(): void {
        panel.visible = !panel.visible;
        if (panel.visible && wifiService.enabled)
            wifiService.scan();
    }

    function open(): void {
        panel.visible = true;
        if (wifiService.enabled)
            wifiService.scan();
    }

    function close(): void {
        panel.visible = false;
    }

    // Main styled background
    Rectangle {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: panel.close()

        color: panel.colBg
        radius: 12
        // border.color: panel.colBgDim
        // border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header Section
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "Wi-Fi"
                    color: panel.colFg
                    font {
                        pixelSize: 13
                        bold: true
                        family: panel.primaryFont
                    }
                }

                // Smooth Pill Toggle Switch
                Rectangle {
                    width: 36
                    height: 20
                    radius: 10
                    color: wifiService.enabled ? "#A3BE8C" : panel.colBgDim // Green when on, theme-dim when off

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    // The switch handle
                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: panel.colFg
                        y: 2
                        x: wifiService.enabled ? parent.width - width - 2 : 2

                        Behavior on x {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wifiService.enabled = !wifiService.enabled;
                            if (wifiService.enabled)
                                wifiService.scan();
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: wifiService.enabled
                    implicitWidth: rescanText.width + 16
                    implicitHeight: rescanText.height + 8
                    color: rescanMouse.containsMouse ? panel.colBgDim : "transparent"
                    radius: 6

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        id: rescanText
                        anchors.centerIn: parent
                        text: wifiService.scanning ? "Scanning…" : "⟳ Rescan"
                        color: panel.accentFill
                        font {
                            family: panel.primaryFont
                            pixelSize: 13
                        }
                    }

                    MouseArea {
                        id: rescanMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wifiService.scan()
                    }
                }
            }

            // Error Text
            Text {
                visible: wifiService.lastError.length > 0 && wifiService.enabled
                text: wifiService.lastError
                color: "#BF616A" // Semantic error color - no theme token for this yet
                wrapMode: Text.WordWrap
                font {
                    pixelSize: 13
                    family: panel.primaryFont
                }
                Layout.fillWidth: true
            }

            // Network List (Hidden when Wi-Fi is off)
            ListView {
                id: networkList
                visible: wifiService.enabled
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: wifiService.networks

                // Visible scrollbar removed - scrolling still works normally

                delegate: Rectangle {
                    required property var modelData

                    width: networkList.width
                    height: 48
                    radius: 8

                    color: modelData.ssid === panel.selectedSsid ? panel.colBgDim // Selected
                    : (netMouse.containsMouse ? panel.colBgDim : "transparent") // Hover

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: modelData.inUse ? "\u25CF" : (modelData.security.length > 0 ? "\uD83D\uDD12" : "\uD83D\uDCF6")
                            color: modelData.inUse ? "#A3BE8C" : panel.colFgDim
                            font.pixelSize: 14
                        }
                        Text {
                            text: modelData.ssid
                            color: modelData.ssid === panel.selectedSsid ? panel.colFg : panel.colFgDim
                            font.bold: modelData.ssid === panel.selectedSsid
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            font.pixelSize: 14
                            font.family: panel.primaryFont
                        }
                        Text {
                            text: modelData.signal + "%"
                            color: panel.colFgDim
                            font.pixelSize: 12
                            font.family: panel.primaryFont
                        }
                    }

                    MouseArea {
                        id: netMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            panel.selectedSsid = modelData.ssid;
                            panel.passwdRequired = modelData.security.length > 0 && !modelData.inUse;
                            passwordField.text = "";

                            console.log("Clicked", passwordField.visible);
                            if (passwordField.visible)
                                passwordField.forceActiveFocus();
                        }
                    }
                }
            }

            // Disabled State Message
            Item {
                visible: !wifiService.enabled
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: "Wi-Fi is turned off"
                    color: panel.colFgDim
                    font.pixelSize: 14
                    font.italic: true
                    font.family: panel.primaryFont
                }
            }

            // Input & Connect Section
            RowLayout {
                visible: panel.passwdRequired && wifiService.enabled
                Layout.fillWidth: true
                spacing: 8

                TextField {
                    id: passwordField
                    visible: panel.passwdRequired
                    placeholderText: "Password"
                    placeholderTextColor: panel.colFgDim
                    color: panel.colFg
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    font.pixelSize: 14
                    font.family: panel.primaryFont

                    background: Rectangle {
                        color: panel.colBgDim
                        radius: 6
                        border.color: passwordField.activeFocus ? panel.accentFill : "transparent"
                        border.width: 1

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    onAccepted: connectButton.clicked()
                }

                Button {
                    id: connectButton
                    text: "Connect"

                    contentItem: Text {
                        text: connectButton.text
                        color: panel.colBg
                        font.bold: true
                        font.family: panel.primaryFont
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        implicitWidth: 80
                        implicitHeight: passwordField.height
                        color: connectButton.down ? panel.colFgDim : panel.accentFill
                        radius: 6
                    }

                    onClicked: {
                        wifiService.connectTo(panel.selectedSsid, passwordField.text);
                        passwordField.text = "";
                        passwordField.visible = false;
                    }
                }
            }
        }
    }
}