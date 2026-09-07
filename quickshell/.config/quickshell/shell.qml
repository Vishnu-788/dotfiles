import Quickshell
import Quickshell.Io
import QtQuick
import "modules/wifi"
import "modules/power-panel"

ShellRoot {
    Scope {
        WifiPanel {
            id: wifiPanel
        }

        PowerPanel {
            id: powerPanel
        }

        // Exposed over Quickshell's IPC so waybar (or a keybind) can call:
        //   qs ipc call wifi toggle
        IpcHandler {
            target: "wifi"

            function toggle(): void {
                wifiPanel.toggle();
            }
            function open(): void {
                wifiPanel.open();
            }
            function close(): void {
                wifiPanel.close();
            }
        }

        IpcHandler {
            target: "power-panel"

            function toggle(): void {
                powerPanel.toggle();
            }
        }
    }
}
