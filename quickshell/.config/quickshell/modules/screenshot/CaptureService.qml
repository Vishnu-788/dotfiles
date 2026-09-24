pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string tempPath: "/tmp/ScreenShots"

    function getTimeStampedName() {
        const d = new Date();
        const pad = n => String(n).padStart(2, "0");

        const date = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
        const time = `${pad(d.getHours())}-${pad(d.getMinutes())}-${pad(d.getSeconds())}`;

        return `screenshot-${date}_${time}`;
    }

    // --- screenshot dispatch process ---
    // NOTE: hyprctl dispatch is fire-and-forget — this process's exit code only
    // reflects whether hyprctl successfully told Hyprland to run the command,
    // NOT whether grim/slurp actually produced a file. Real success/failure
    // comes from captureWatchTimer below, which polls for the file itself.
    property bool captureInProgress: false
    property string lastPath: ""
    property string lastStderr: ""

    function getLastPath() {
        return root.lastPath;
    }

    Process {
        id: shotProc

        stdout: SplitParser {
            onRead: data => console.log("[shotProc stdout]", data)
        }

        stderr: SplitParser {
            onRead: data => console.log("[shotProc stderr]", data)
        }

        onExited: (exitCode, exitStatus) => {
            console.log(`[shotProc] hyprctl dispatch exited code=${exitCode} at ${Date.now()} and exit status: ${exitStatus}`);
        }
    }



    Timer {
        id: captureWatchTimer
        interval: 300
        repeat: true
        property int elapsedMs: 0
        property int timeoutMs: 30000 // give up after 30s (e.g. user cancelled slurp)

        onTriggered: {
            elapsedMs += interval;
            if (elapsedMs >= timeoutMs) {
                stop();
                root.captureInProgress = false;
                root.notify("Screenshot", "Capture timed out or was cancelled", "critical");
                return;
            }
            checkFileProc.exec(["test", "-f", root.lastPath]);
        }
    }

    function runCapture(mode) {
        if (captureInProgress) {
            return;
        }
        captureInProgress = true;

        const path = root.tempPath + "/" + getTimeStampedName() + ".png";
        let shellCmd;
        if (mode === "region") {
            shellCmd = `grim -g \\"$(slurp)\\" ${path}`;
        } else {
            shellCmd = `grim ${path}`;
        }
        root.lastPath = path;

        const luaExpr = `hl.dsp.exec_cmd("mkdir -p ${root.tempPath} && ${shellCmd}")`;
        const fullCmd = ["hyprctl", "dispatch", luaExpr];
        shotProc.exec(fullCmd);
    }

    property string pendingCaptureMode: ""

    Timer {
        id: captureDelay
        interval: 300
        repeat: false
        onTriggered: root.runCapture(root.pendingCaptureMode)
    }

    function requestCapture(mode) {
        pendingCaptureMode = mode;
        captureDelay.start();
    }

    function capture(optId, opt) {
        console.log(`opt: ${optId}: ${opt.name}`);
        switch (optId) {
        case 0:
            requestCapture("full-screen");
            break;
        case 1:
            requestCapture("region");
            break;
        case 2:
            startTimer("full-screen", 3);
            break;
        case 3:
            startTimer("region", 3);
            break;
        }
    }

    Timer {
        id: countdown
        property int secondsLeft: 0
        property string pendingMode: ""
        interval: 1000
        repeat: true

        onTriggered: {
            secondsLeft -= 1;
            if (secondsLeft > 0) {
                root.notify("Screenshot", secondsLeft + "…", "low");
            } else {
                running = false;
                root.runCapture(pendingMode);
            }
        }
    }

    function startTimer(mode, delaySeconds) {
        countdown.pendingMode = mode;
        countdown.secondsLeft = delaySeconds;
        countdown.running = true;
    }
}
