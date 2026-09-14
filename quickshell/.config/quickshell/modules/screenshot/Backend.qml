pragma Singleton
import QtQuick
import QtCore

QtObject {
    property var options: [
        { id: "fullscreen",       name: "Full Screen",              icon: "screenshot-fullscreen-symbolic", delay: 0 },
        { id: "region",           name: "Region",                   icon: "screenshot-area-symbolic",       delay: 0 },
        { id: "fullscreen_delay", name: "Full Screen - Delay(3s)",  icon: "screenshot-fullscreen-symbolic", delay: 3 },
        { id: "region_delay",     name: "Region - Delay(3s)",       icon: "screenshot-area-symbolic",       delay: 3 }
    ]

    property bool panelVisible: false

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
        if (!opt) return;

        switch (opt.id) {
        case "fullscreen":
            // trigger fullscreen capture
            break;
        case "region":
            // trigger region capture
            break;
        case "fullscreen_delay":
            // trigger fullscreen capture after opt.delay seconds
            break;
        case "region_delay":
            // trigger region capture after opt.delay seconds
            break;
        }
    }
}
