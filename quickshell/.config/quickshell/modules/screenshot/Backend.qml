pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
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

    enum CaptureState {
        Idle,
        Captured,
        Failed
    }

    property string saveDir: Quickshell.env("HOME") + "/Pictures/Screenshots"
    property bool panelVisible: false
    property int captureState: Backend.CaptureState.Idle
    property var pendingAction: null
    property string filePath: ""
    readonly property bool isCapturing: CaptureService.isCapturing()

    Connections {
        target: CaptureService

        function onScreenshotCaptured(filePath) {
            Backend.captureState = Backend.CaptureState.Captured;
            root.filePath = filePath;
            Backend.show();
        }

        function onScreenshotFailed(code, err) {
            root.notify("Screenshot Failed", `Exitcode: ${code}, Err: ${err}`);
            Backend.close();
            console.log(`Exit code: ${code}, Err: ${err}`);
        }
    }

    Process {
        id: notifyProc
    }

    Process {
        id: actionProc
        property string lastAction: ""

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                const messages = {
                    "save": "Screenshot saved",
                    "copy": "Screenshot copied to clipboard",
                    "saveAndCopy": "Screenshot saved and copied"
                };
                root.notify("Screenshot", messages[lastAction] || "Action complete");
            } else {
                root.notify("Screenshot", "Action failed (exit code " + exitCode + ")");
            }
        }
    }

    Timer {
        id: delayTimer
        repeat: false
        onTriggered: {
            if (root.pendingAction) {
                root.pendingAction();
                root.pendingAction = null;
            }
        }
    }

    function toggle() {
        if (panelVisible) {
            panelVisible = false;
        } else {
            panelVisible = true;
        }
    }

    function show() {
        panelVisible = true;
    }

    function hide() {
        panelVisible = false;
    }

    function close() {
        panelVisible = false;
        root.filePath = "";
        captureState = Backend.CaptureState.Idle;
    }

    function notify(summary, body) {
        notifyProc.command = ["notify-send", summary, body];
        notifyProc.running = true;
    }

    function save() {
        actionProc.lastAction = "save";
        actionProc.command = ["sh", "-c", `mkdir -p ${saveDir} && mv ${filePath} ${saveDir}/`];
        actionProc.running = true;
    }

    function copy() {
        actionProc.lastAction = "copy";
        actionProc.command = ["sh", "-c", `wl-copy --type image/png < "${filePath}"`];
        actionProc.running = true;
    }

    function saveAndCopy() {
        actionProc.lastAction = "saveAndCopy";
        actionProc.command = ["sh", "-c", `mkdir -p ${saveDir} && cp ${filePath} ${saveDir}/ && wl-copy --type image/png < "${filePath}"`];
        actionProc.running = true;
    }

    function handleAction(actionId) {
        if (filePath === "") {
            Backend.close();
            notify("Screenshot Failed", "File path is empty.");
            return;
        }

        switch (actionId) {
        case 0: // Copy
            copy();
            break;
        case 1: // Save
            save();
            break;
        case 2: // Save and Copy
            saveAndCopy();
            break;
        }

        root.close();
    }

    function runAfter(ms, action) {
        pendingAction = action;
        delayTimer.interval = ms;
        delayTimer.start();
    }

    function handleScreenshot(optionId) {
        Backend.hide();
        switch (optionId) {
        case 0: // full-screen
            runAfter(200, () => CaptureService.captureFullscreen());
            break;
        case 1: // region
            runAfter(200, () => CaptureService.captureSlurp());
            break;
        case 2: // full-screen delay-3s
            runAfter(3000, () => CaptureService.captureFullscreen());
            break;
        case 3: // region delay - 3s
            runAfter(3000, () => CaptureService.captureSlurp());
            break;
        }
    }
}
