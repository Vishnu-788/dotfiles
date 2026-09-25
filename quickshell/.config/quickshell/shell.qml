import Quickshell
import QtQuick
import "modules/wifi"
import "modules/power-panel"
import "modules/app-launcher"
import "modules/screenshot"
import "modules/screenshottemp"

ShellRoot {
    WifiPanel {}
    PowerPanel {}
    AppLauncher {}
    ScreenShot {}
    ScreenshotTemp {}
}
