import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

PanelWindow {
    id: panel
    visible: false
    implicitWidth: 340
    implicitHeight: 240
    color: "transparent"

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    IpcHandler {
        target: "power-panel"

        function toggle(): void {
            panel.toggle();
        }
    }

    PowerService {
        id: service
    }

    property int currentIndex: 0

    property var actions: [
        {
            label: "Power Off",
            icon: "\u{F0425}",
            run: () => service.poweroff()
        },
        {
            label: "Reboot",
            icon: "\u{F0709}",
            run: () => service.reboot()
        },
        {
            label: "Sleep",
            icon: "\u{F04B2}",
            run: () => service.sleep()
        },
        {
            label: "Hibernate",
            icon: "\u{F040A}",
            run: () => service.hibernate()
        },
    ]

    function toggle(): void {
        panel.visible = !panel.visible;
    }
    function open(): void {
        panel.visible = true;
    }
    function close(): void {
        panel.visible = false;
    }

    onVisibleChanged: {
        if (visible) {
            currentIndex = 0;
            listArea.forceActiveFocus();
        }
    }

    function activateCurrent() {
        actions[currentIndex].run();
        panel.close();
    }

    Rectangle {
        id: listArea
        anchors.fill: parent
        color: "#11141C"
        radius: 12
        border.color: "#3B4252"
        border.width: 1
        focus: true

        Keys.onEscapePressed: panel.close()
        Keys.onReturnPressed: panel.activateCurrent()
        Keys.onEnterPressed: panel.activateCurrent()
        Keys.onDownPressed: panel.currentIndex = (panel.currentIndex + 1) % panel.actions.length
        Keys.onUpPressed: panel.currentIndex = (panel.currentIndex - 1 + panel.actions.length) % panel.actions.length
        Keys.onTabPressed: panel.currentIndex = (panel.currentIndex + 1) % panel.actions.length
        Keys.onBacktabPressed: panel.currentIndex = (panel.currentIndex - 1 + panel.actions.length) % panel.actions.length

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 0

            Repeater {
                model: panel.actions

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 8
                    color: (index === panel.currentIndex) ? "#3B4252" : (rowArea.containsMouse ? "#2A2C38" : "#242530")
                    border.color: index === panel.currentIndex ? "#88C0D0" : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 14

                        Text {
                            text: modelData.icon
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 18
                            color: "#88C0D0"
                            Layout.preferredWidth: 24
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: modelData.label
                            color: "#ECEFF4"
                            font.pixelSize: 13
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: panel.currentIndex = index
                        onClicked: panel.activateCurrent()
                    }
                }
            }
        }
    }
}
