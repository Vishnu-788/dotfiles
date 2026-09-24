import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

PanelWindow {
    id: win
    property bool shown: false
    visible: shown && !Backend.capturing
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    mask: Region {
        item: box
    }

    focusable: Backend.focused

    Rectangle {
        id: box
        anchors.centerIn: parent
        width: 300
        height: 300
        color: "#1e1e2e"

        Button {
            anchors.centerIn: parent
            text: "All do it"
            onClicked: Backend.capture()
        }
    }

    IpcHandler {
        target: "capture"
        function toggle(): void {
            shown = !shown;
        }
    }
}
