pragma Singleton
import QtQuick
import Quickshell
import QtCore
import Quickshell.Io

QtObject {
    property var options: [
        {
            id: 0,
            name: "Full Screen",
            icon: "screenshot-fullscreen-symbolic",
            delay: 0
        },
        {
            id: 1,
            name: "Region",
            icon: "screenshot-area-symbolic",
            delay: 0
        },
        {
            id: 2,
            name: "Full Screen - Delay(3s)",
            icon: "screenshot-fullscreen-symbolic",
            delay: 3
        },
        {
            id: 3,
            name: "Region - Delay(3s)",
            icon: "screenshot-area-symbolic",
            delay: 3
        }
    ]

    property var fileActions: [
        {
            id: 0,
            name: "Copy",
            icon: "screenshot-fullscreen-symbolic"
        },
        {
            id: 1,
            name: "Save",
            icon: "screenshot-area-symbolic"
        },
        {
            id: 2,
            name: "Copy & Save",
            icon: "screenshot-fullscreen-symbolic"
        },
    ]

    property string screenshotDir: Quickshell.env("HOME") + "/Pictures/Screenshots"

    property bool panelVisible: false
    property bool captured: false

    // --- notifications ---
    // Process {
    //     id: notifyProc
    // }
    //
    // function notify(summary, body, urgency) {
    //     notifyProc.exec(["notify-send", "-u", urgency || "normal", "-t", "3000", summary, body || ""]);
    // }
    //
    function toggle() {
        panelVisible = !panelVisible;
    }

    function show() {
        panelVisible = true;
    }

    function hide() {
        panelVisible = false;
    }

    function handleScreenShot(optionId) {
        const opt = options.find(o => o.id === optionId);
        if (!opt)
            return;
        CaptureService.capture(optionId, opt);
    }
}
