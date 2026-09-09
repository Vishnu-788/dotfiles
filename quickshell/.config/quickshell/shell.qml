import Quickshell
import Quickshell.Io
import QtQuick
import "modules/wifi"
import "modules/power-panel"
import "modules/app-launcher"

ShellRoot {
    Scope {
        WifiPanel {
            id: wifiPanel
        }

        PowerPanel {
            id: powerPanel
        }

        AppLauncher {
            id: appLauncher
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

        IpcHandler {
            target: "app-launcher"
            function toggle() {
               appLauncher.toggle()
            }
        }
    }
}
