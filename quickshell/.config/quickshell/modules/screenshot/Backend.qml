pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    // --- capture completion watcher (polls for the file since hyprctl exec is fire-and-forget) ---
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

    property string screenshotDir: Quickshell.env("HOME") + "/Pictures/Screenshots"
    property bool panelVisible: false
    property int shotState: Backend.CaptureState.Idle
    property bool isFocused: true

    Process {
        id: fileCheckProc
        stderr: StdioCollector {
            id: captureErr
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                root.panelVisible = true;
                root.shotState = Backend.CaptureState.Captured;
                console.log("Success");
                root.notify("Screenshot is success", captureErr.text, "low");
            } else {
                console.log("Failed");
                console.log("text: " + captureErr.text);
                console.log("code: " + exitCode);
                Backend.handleFailure();
                root.notify("Screenshot Failed", captureErr.text, "critical");
            }
            root.isFocused = true;
        }
    }

    Process {
        id: notifyProc
        running: false
    }

    Timer {
        id: verifyTimer
        interval: 1000
        repeat: false
        running: false
        onTriggered: fileCheckProc.running = true
    }

    function runFileCheck() {
        fileCheckProc.command = ["test", "-e", CaptureService.getLastPath()];
        verifyTimer.restart();
    }

    function notify(title, body, urgencyLevel) {
        notifyProc.command = ["notify-send", "-u", urgencyLevel, title, body];
        notifyProc.running = true;
    }

    function toggle() {
        if (panelVisible) {
            panelVisible = false;
        } else {
            panelVisible = true;
        }
    }

    function handleFailure() {
        panelVisible = false;
        shotState = Backend.CaptureState.Idle;
    }

    function show() {
        panelVisible = true;
    }

    function hide() {
        panelVisible = false;
    }

    function close() {
        hide();
    }

    function performAction(actionId) {
        const act = fileActions.find(a => a.id === actionId);
        const fileTempPath = CaptureService.getLastPath();

        switch (actionId) {
        case 0: // Save
            break;
        case 1: // Copy
            break;
        case 2: // Save and Copy
            break;
        }
    }

    function handleScreenShot(optionId) {
        const opt = options.find(o => o.id === optionId);
        root.isFocused = false;
        if (!opt)
            return;
        CaptureService.capture(optionId, opt);
        runFileCheck();
    }
}
