import Quickshell
import Quickshell.Io
import QtQuick
import "modules/wifi"
import "modules/power-panel"
import "modules/app-launcher"

ShellRoot {
    WifiPanel {}
    PowerPanel {}
    AppLauncher {}
}
