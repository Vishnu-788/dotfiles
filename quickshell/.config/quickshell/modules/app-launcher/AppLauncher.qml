import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

PanelWindow {
    id: root
    property var screen

    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
}
