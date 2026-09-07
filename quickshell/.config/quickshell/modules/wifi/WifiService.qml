import Quickshell.Io
import QtQuick

// Reactive wrapper around nmcli. Exposes `networks`, `scanning`,
// `activeSsid`, `lastError`, and `enabled` to the UI.
QtObject {
    id: root

    property var networks: []
    property bool scanning: false
    property string activeSsid: ""
    property string lastError: ""
    
    // New: Wi-Fi Power State
    property bool enabled: false
    property bool _isInternalUpdate: false // Prevents loop when updating from system check

    // Check Wi-Fi state when the backend is initialized
    Component.onCompleted: {
        checkRadioProcess.running = true;
    }

    function scan(): void {
        if (!enabled) return; // Prevent scanning if Wi-Fi is disabled
        scanning = true;
        scanProcess.running = true;
    }

    function connectTo(ssid: string, password: string): void {
        if (!enabled) return;
        lastError = "";
        connectProcess.command = password.length > 0
            ? ["nmcli", "device", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "device", "wifi", "connect", ssid];
        connectProcess.running = true;
    }

    // React to the UI toggle switch
    onEnabledChanged: {
        if (_isInternalUpdate) return;
        
        // Clear networks immediately when turning off for a snappy UI
        if (!enabled) {
            networks = [];
            activeSsid = "";
        }
        
        radioSetProcess.command = ["nmcli", "radio", "wifi", enabled ? "on" : "off"];
        radioSetProcess.running = true;
    }

    // --- System Processes ---

    // 1. Checks if Wi-Fi is currently on or off
    property Process checkRadioProcess: Process {
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const state = this.text.trim();
                root._isInternalUpdate = true;
                root.enabled = (state === "enabled");
                root._isInternalUpdate = false;
                
                if (root.enabled) {
                    root.scan();
                }
            }
        }
    }

    // 2. Applies the on/off state to NetworkManager
    property Process radioSetProcess: Process {
        running: false
        onExited: {
            if (root.enabled) {
                root.scan();
            }
        }
    }

    // 3. Scans for networks
    // -t = terse/colon-separated (script-friendly), -f picks exact fields
    property Process scanProcess: Process {
        running: false
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0);
                const parsed = lines.map(line => {
                    const parts = line.split(":");
                    return {
                        inUse: parts[0] === "*",
                        signal: parseInt(parts[1] || "0", 10),
                        security: parts[2] || "",
                        ssid: parts[3] && parts[3].length > 0 ? parts[3] : "(hidden network)",
                    };
                });

                // Networks with multiple APs (mesh, repeaters) show up as
                // duplicate SSID rows — keep only the strongest signal.
                const strongest = {};
                for (const n of parsed) {
                    if (!strongest[n.ssid] || strongest[n.ssid].signal < n.signal) {
                        strongest[n.ssid] = n;
                    }
                }

                root.networks = Object.values(strongest).sort((a, b) => b.signal - a.signal);
                const current = parsed.find(n => n.inUse);
                root.activeSsid = current ? current.ssid : "";
                root.scanning = false;
            }
        }
    }

    // 4. Connects to a network
    property Process connectProcess: Process {
        running: false
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0) {
                    root.lastError = this.text.trim();
                }
            }
        }
        onExited: root.scan()
    }
}
