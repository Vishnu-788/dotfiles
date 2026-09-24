// Backend.qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool capturing: false

    signal captured(string path)   // emitted on success
    signal cancelled()             // emitted on Escape or error

    Process {
        id: proc
        command: ["sh", "-c", [
            "dir=\"/tmp/Screenshots\"",
            "mkdir -p \"$dir\"",
            "f=\"$dir/$(date +%Y%m%d-%H%M%S).png\"",
            "geom=$(slurp </dev/null) || exit 1",   // stdin fix + bail out if cancelled
            "grim -g \"$geom\" \"$f\" || exit 2",
            "echo \"$f\""
        ].join("; ")]

        stdout: StdioCollector { id: out }
        stderr: StdioCollector { id: err }

        onExited: (code, status) => {
            root.capturing = false
            if (code === 0) {
                console.log("saved:", out.text.trim())
                root.captured(out.text.trim())
            } else {
                console.log("capture failed/cancelled, code", code, err.text.trim())
                root.cancelled()
            }
        }
    }

    function capture() {
        if (proc.running) return
        capturing = true
        proc.running = true
    }
}