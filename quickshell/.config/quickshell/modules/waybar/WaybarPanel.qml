import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
   id: root

   property string fontFamily: "JetbrainsMono Nerd Font"

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30

    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        Repeater {
            model: 6
            Text {
                id: workspaceLabel
                required property int index
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                text: index + 1
                color: isActive ? "#0db9d7" : (ws ? "#7aa2f7" : "#444b6a")
                font {
                    pixelSize: 14
                    bold: true
                }
                // TODO: Hyprland migration from conf to lua do the dispatch function isn;t updated to make it work.
                // Rn i have created the string converter which somehow works for now. Change this to appropirate one in the future.j
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = ' + (workspaceLabel.index + 1) + ' })')
                }
            }
        }
        Item {
            Layout.fillWidth: true
        }
     }

     Process {
        id: cpuProcess

     }
}
