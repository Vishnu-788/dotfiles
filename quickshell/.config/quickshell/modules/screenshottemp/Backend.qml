// Backend.qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool focused: true
    property bool capturing: false

    Process {
        id: proc
        // exec replaces the shell with slurp, so the exit code below is slurp's own
        command: ["sh", "-c", "exec slurp </dev/null"]

        stdout: StdioCollector {
            id: out
        }
        stderr: StdioCollector {
            id: err
        }

        onStarted: console.log("slurp started")
        onExited: (code, status) => {
            console.log("exited with code", code, "geometry:", out.text.trim(), "stderr:", err.text.trim());
            root.focused = true;
            root.capturing = false;
        }
    }

    Timer {
        id: captureTimer
        interval: 200
        onTriggered: {
            console.log("Calling the process");
            proc.running = true;
        }
    }

    function capture() {
        capturing = true;
        focused = false;
        captureTimer.start();
        console.log("Triggered");
    }
}