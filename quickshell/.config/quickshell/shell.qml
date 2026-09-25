import Quickshell
import QtQuick
import "modules/wifi"
import "modules/power-panel"
import "modules/app-launcher"
import "modules/screenshot"

ShellRoot {
    WifiPanel {}
    PowerPanel {}
    AppLauncher {}
    ScreenShot {}
}
