pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    signal screenshotCaptured(string path)
    signal screenshotFailed(string code, string err)

    // Function to get the screenshot name.
    function getTimeStampedName() {
        const d = new Date();
        const pad = n => String(n).padStart(2, "0");

        const date = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
        const time = `${pad(d.getHours())}-${pad(d.getMinutes())}-${pad(d.getSeconds())}`;

        return `screenshot-${date}-${time}`;
    }

    property string tempPath: "/tmp/ScreenShots"
    property bool capturing: false

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
            if (code === 0) {
                root.screenshotCaptured(captureOut.text.trim());
            } else {
                root.screenshotFailed(code, captureErr.text.trim());
            }

            root.capturing = false;
        }
    }

    function runCapture(script, path) {
        if (captureProcess.running)
            return;
        capturing = true;
        captureProcess.command = ["sh", "-c", script, "sh", path];
        captureProcess.running = true;
    }

    function captureFullscreen() {
        const path = `${tempPath}/${getTimeStampedName()}.png`;
        runCapture(['mkdir -p "$(dirname "$1")"', 'grim "$1" || exit 2', 'echo "$1"'].join("; "), path);
    }

    function captureSlurp() {
        const path = `${tempPath}/${getTimeStampedName()}.png`;
        runCapture(['mkdir -p "$(dirname "$1")"', 'geom=$(slurp </dev/null) || exit 1', 'grim -g "$geom" "$1" || exit 2', 'echo "$1"'].join("; "), path);
    }
}
