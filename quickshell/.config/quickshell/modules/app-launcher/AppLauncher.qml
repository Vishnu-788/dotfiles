import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "../../theme"

PanelWindow {
    id: root
    property var scr

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: AppLauncherState.launcherVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-launcher"

    IpcHandler {
        target: "app-launcher"
        function toggle() {
            root.toggle();
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    mask: Region {
        item: AppLauncherState.launcherVisible ? maskCover : null
    }

    Item {
        id: maskCover
        anchors.fill: parent
    }

    color: "transparent"

    // Theme Colors 
    property string primaryFont: FontFamily.jetBrains
    property color colFg: Colors.colFg
    property color colFgDim: Colors.colFgDim
    property color colBg: Colors.colBg
    property color colBgDim: Colors.colBgDim
    property color accentFill: Colors.accentFill


    property string searchQuery: ""
    property int selectedIdx: 0
    readonly property bool isSearching: searchQuery.trim() !== ""

    property var filteredApps: {
        var q = searchQuery.trim().toLowerCase();
        var vals = DesktopEntries.applications.values;

        if (q !== "") {
            return vals.filter(function (e) {
                if (e.name.toLowerCase().indexOf(q) !== -1)
                    return true;
                if (e.genericName && e.genericName.toLowerCase().indexOf(q) !== -1)
                    return true;
                for (var i = 0; i < e.keywords.length; i++) {
                    if (e.keywords[i].toLowerCase().indexOf(q) !== -1)
                        return true;
                }
                return false;
            }).sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
        } else {
            var recent = AppLauncherState.recentIds;
            return vals.slice().sort(function (a, b) {
                var ai = recent.indexOf(a.id);
                var bi = recent.indexOf(b.id);

                if (ai !== -1 && bi !== -1)
                    return ai - bi;
                if (ai !== -1)
                    return -1;
                if (bi !== -1)
                    return 1;
                return a.name.localeCompare(b.name);
            });
        }
    }

    onFilteredAppsChanged: selectedIdx = 0

    function toggle() {
        AppLauncherState.toggle();
    }

    function launchEntry(entry) {
        AppLauncherState.recordLaunch(entry.id);
        entry.execute();
        AppLauncherState.hide();
    }

    function navigate(delta) {
        if (filteredApps.length === 0)
            return;
        selectedIdx = (selectedIdx + delta + filteredApps.length) % filteredApps.length;
        listView.positionViewAtIndex(selectedIdx, ListView.Contain);
    }

    Connections {
        target: AppLauncherState
        function onLauncherVisibleChanged() {
            if (AppLauncherState.launcherVisible) {
                searchInput.text = "";
                root.searchQuery = "";
                root.selectedIdx = 0;
                searchInput.forceActiveFocus();
            }
        }
    }

    readonly property int maxVisible: 7
    readonly property int itemH: 48
    readonly property int panelW: 540
    readonly property int panelH: 108 + Math.min(filteredApps.length, maxVisible) * itemH

    MouseArea {
        anchors.fill: parent
        enabled: AppLauncherState.launcherVisible
        onClicked: AppLauncherState.hide()
    }

    // AppLauncher UI

    Rectangle {
        id: panel
        width: root.panelW
        height: root.panelH
        anchors.centerIn: parent

        Behavior on height {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        clip: true

        color: root.colBg
        radius: 18
        // border.color: Qt.alpha("#11141C", 0.10)
        border.width: 1

        opacity: AppLauncherState.launcherVisible ? 1 : 0
        scale: AppLauncherState.launcherVisible ? 1 : 0.92
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            // swallow clicks so they don't fall through to the hide() MouseArea behind
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            id: searchColumn
            anchors {
                top: parent.top
                topMargin: 12
                left: parent.left
                leftMargin: 12
                right: parent.right
                rightMargin: 12
            }
            spacing: 0

            // Search bar

            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                // color: Qt.alpha("#11141C", 0.8)
                color: root.colBg

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    opacity: searchInput.activeFocus ? 0.55 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 14
                        topMargin: 14
                    }
                    spacing: 10

                    Row {
                        width: parent.width - 40
                        height: parent.height
                        spacing: 10

                        Text {
                            text: "\uf002"   // nf-fa-search
                            color: root.colFg
                            font {
                                pixelSize: 13
                                family: root.primaryFont
                            }
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text: "Search Apps..."
                            color: root.colFg
                            opacity: 0.28
                            font {
                                pixelSize: 13
                                family: root.primaryFont
                            }
                            verticalAlignment: Text.AlignVCenter
                            visible: searchInput.text === ""
                        }

                        TextInput {
                            id: searchInput
                            color: root.colFg
                            selectionColor: root.accentFill
                            font {
                                pixelSize: 13
                                family: root.primaryFont
                            }
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true

                            onTextChanged: root.searchQuery = text

                            Keys.onPressed: function (event) {
                                if (event.key === Qt.Key_Up) {
                                    root.navigate(-1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down) {
                                    root.navigate(1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                                    if (event.modifiers & Qt.ShiftModifier || event.key === Qt.Key_Backtab) {
                                        root.navigate(-1);
                                    } else {
                                        root.navigate(1);
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (root.filteredApps.length > 0)
                                        root.launchEntry(root.filteredApps[root.selectedIdx]);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    AppLauncherState.hide();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }
            }
        }

        ListView {
            id: listView
            anchors {
                top: searchColumn.bottom
                topMargin: 8
                left: parent.left
                right: parent.right
            }
            height: Math.min(root.filteredApps.length, root.maxVisible) * root.itemH
            model: root.filteredApps
            clip: true
            interactive: false

            MouseArea {
                anchors.fill: parent
                onWheel: function (wheel) {
                    if (wheel.angleDelta.y < 0) {
                        root.navigate(1);
                    } else {
                        root.navigate(-1);
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.filteredApps.length === 0
                text: "No apps found"
                color: Colors.colFg
                opacity: 0.28
                font {
                    pixelSize: 13
                    family: root.primaryFont
                }
            }

            delegate: Item {
                id: appRow
                width: listView.width
                height: root.itemH
                required property int index
                required property var modelData

                readonly property bool sel: root.selectedIdx === index
                readonly property bool isRecent: !root.isSearching && AppLauncherState.recentIds.indexOf(modelData.id) !== -1 && AppLauncherState.recentIds.indexOf(modelData.id) < 5

                Rectangle {
                    anchors {
                        fill: parent
                        topMargin: 2
                        bottomMargin: 2
                    }
                    color: appRow.sel ? root.colBgDim : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Row {
                        anchors {
                            fill: parent
                            leftMargin: 8
                            rightMargin: 8
                        }
                        spacing: 12

                        // Icon Bubble
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            color: "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }

                            Image {
                                id: appIcon
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                source: modelData.icon !== "" ? "image://icon/" + modelData.icon : ""
                                smooth: true
                                mipmap: true
                            }

                            // Fallback if no icon is provided
                            Text {
                                anchors.centerIn: parent
                                visible: appIcon.status !== Image.Ready
                                text: modelData.name.charAt(0).toUpperCase()
                                font {
                                    pixelSize: 15
                                    family: root.primaryFont
                                    weight: Font.Bold
                                }
                                color: "transparent"
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: modelData.name
                                font {
                                    pixelSize: 13
                                    family: root.primaryFont
                                    weight: appRow.sel ? Font.Medium : Font.Normal
                                }
                                color: appRow.sel ? Colors.colFg : root.colFgDim
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }
                                }
                            }
                            Row {
                                spacing: 6
                                visible: appRow.isRecent || modelData.genericName !== ""

                                Rectangle {
                                    visible: appRow.isRecent
                                    width: recentLabel.width + 8
                                    height: 14
                                    radius: 4
                                    color: root.accentFill
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        id: recentLabel
                                        anchors.centerIn: parent
                                        text: "recent"
                                        font {
                                            pixelSize: 9
                                            family: root.primaryFont
                                        }
                                        color: root.colBg
                                    }
                                }
                                Text {
                                    visible: modelData.genericName !== ""
                                    text: modelData.genericName
                                    font {
                                        pixelSize: 11
                                        family: root.primaryFont
                                    }
                                    color: Colors.colFg
                                    opacity: 0.35
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.launchEntry(appRow.modelData)
                    }
                }
            }
        }
    }
}
