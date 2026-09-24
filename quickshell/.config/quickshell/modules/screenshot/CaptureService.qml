pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Function to get the screenshot name.
    function getTimeStampedName() {
        const d = new Date();
        const pad = n => String(n).padStart(2, "0");

        const date = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
        const time = `${pad(d.getHours())}-${pad(d.getMinutes())}-${pad(d.getSeconds())}`;

        return `screenshot-${date}-${time}`;
    }

    property string tempPath: "/tmp/ScreenShots"

    property bool captureInProgress: false
    property string lastPath: ""
    property string lastStderr: ""

    property bool capturing: false

    signal captured(string path)
    signal cancelled

    function getLastPath() {
        return root.lastPath;
    }

    function isCapturing() {
        return root.capturing;
    }

    Process {
        id: captureProcess

        stdout: StdioCollector {
            id: captureOut
        }
        stderr: StdioCollector {
            id: captureErr
        }

        onExited: (code, status) => {
            root.capturing = false;
            if (code === 0) {
                root.captured(captureOut.text.trim());
            } else {
                console.log("capture failed/cancelled, code", code, captureErr.text.trim());
                root.cancelled();
            }
        }
    }

    function runCapture(script, path) {
        if (captureProcess.running)
            return;
        capturing = true;
        captureProcess.command = ["sh", "-c", script, "sh", path];
        captureProcess.running = true;
    }

    function captureFullScreen() {
        const path = `${tempPath}/${getTimeStampedName()}.png`;
        root.lastPath;
        runCapture(['mkdir -p "$(dirname "$1")"', 'grim "$1" || exit 2', 'echo "$1"'].join("; "), path);
    }

    function captureSlurp() {
        const path = `${tempPath}/${getTimeStampedName()}.png`;
        root.lastPath;
        runCapture(['mkdir -p "$(dirname "$1")"', 'geom=$(slurp </dev/null) || exit 1', 'grim -g "$geom" "$1" || exit 2', 'echo "$1"'].join("; "), path);
    }
}
