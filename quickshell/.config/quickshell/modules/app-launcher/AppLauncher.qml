import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

PanelWindow {
    id: root
    property var scr

    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    property string searchQuery: ""
    property int selectedIdx: 0
    readonly property bool isSelected: searchQuery.trim() !== ""

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

    function launchEntry(entry) {
        AppLauncherState.recordLaunch(entry.id);
        entry.execute();
        AppLauncherState.hide();
    }

    function navigate(delta) {
        if (filteredApps.length === 0)
            return;
        selectedIdx = (selectedIdx + delta + filteredApps.length) % filteredApps.length;
        ListView.positionViewAtIndex(selectedIdx, ListView.Contain);
    }

    Connections {
        target: AppLauncherState
        function onLaunchVisibleChanged() {
            if (AppLauncherState.launcherVisible) {
                searchInput.text = "";
                root.searchQuery = "";
                root.selectedIdx = 0;
                searchInput.forceActiveFocus();
            }
        }
    }

    readonly property color accentFill: Qt.rgba(Colors.colBlue.r, Colors.colBlue.g, Colors.colBlue.b, 0.18)
    readonly property color acccenticon: Qt.rgba(Colors.colBlue.r, Colors.colBlue.g, Colors.colBlue.b, 0.28)
    readonly property color fgDim: Qt.rgba(Colors.colFg.r, Colors.colFg.g, Colors.colFg.b, 0.65)

    readonly property int maxVisible: 7
    readonly property int itemH: 42
    readonly property int panelW: 440

    readonly property int panelH: 88 + Math.min(filteredApps.length, maxVisible) * itemH

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
        Behavior on height {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        clip: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        color: Qt.rgba(Colors.colBg.r, Colors.colBg.g, Colors.colBg.b, 0.8)
        topLeftRadius: 18
        topRightRadius: 18
        bottomLeftRadius: 0
        bottomRightRadius: 0
        border.color: Qt.alpha(Colors.colFg, 0.10)
        border.width: 1

        transform: Translate {
            y: AppLauncherState.launcherVisible ? 0 : root.panelH + 6
            Behavior on y {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }
        }

        Column {
            anchors {
                top: parent.top
                topMargin: 12
                left: parent.left
                leftMargin: 12
                right: parent.right
                rightMargin: 12
            }
            spacing: 0

            Rectangle {
                width: 36
                height: 4
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.rgba(1, 1, 1, 0.22)
            }

            Item {
                width: 1
                height: 8
            }

            // Search bar

            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.07)

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    border.color: Colors.colBlue
                    border.width: 1
                    opacity: searchInput.activeFocus ? 0.55 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    Row {
                        anchors: {
                            fill: parent;
                            leftMargin: 14;
                            rightMargin: 14;
                        }
                        spacing: 10
                        Item {
                            width: parent.width - 40
                            height: parent.height

                            Text {
                                anchors.fill: parent
                                text: root.isSearching ? "" : "Search Apps..."
                                color: Colors.colFg
                                opacity: 0.28
                                font {
                                    pixelSize: 13
                                    family: "JetBrainsMono Nerd Font"
                                }
                                verticalAlignment: Text.AlignVCenter
                                visible: searchInput.text === ""
                            }
                        }
                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            color: Colors.colFg
                            selectionColor: root.accentFill
                            font {
                                pixelSize: 13
                                family: "JetBrainsMono Nerd Font"
                            }
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true

                            onTextChanged: root.searchQuery = text
                        }

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Up) {
                                root.navigate(-1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                root.navigate(1);
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
        Item {
            width: 1
            height: 0
        }

        ListView {
            id: listView
            width: parent.width
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
                    family: "JetBrainsMono Nerd Font"
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
                    anchors: {
                        fill: parent;
                        topMargin: 2;
                        bottomMargin: 2;
                    }
                    radius: 10
                    color: appRow.sel ? root.accentFill : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }

                Row {
                    anchors: {
                        fill: parent;
                        leftMargin: 8;
                        rightMargin: 8;
                    }
                    spacing: 12

                    // Icon Bubble

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 9
                        anchors.verticalAlignment: parent.verticalCenter
                        color: appRow.sel ? root.accentIcon : Qt.rgba(1, 1, 1, 0.08)
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
                                family: "JetBrainsMono Nerd Font"
                                weight: Font.Bold
                            }
                            color: appRow.sel ? Colors.colBlue : Colors.colFg
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
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
                                    family: "JetBrainsMono Nerd Font"
                                    weight: appRow.sel ? Font.Medium : Font.Normal
                                }
                                color: appRow.sel ? Colors.colFg : root.fgDim
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
                                    width: recentLabel.width + 0
                                    height: 14
                                    radius: 4
                                    color: Qt.rgba(Colors.colBlue.r, Colors.colBlue.g, Colors.colBlue.b, 0.22)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        id: recentLabel
                                        anchors.centerIn: parent
                                        text: "recent"
                                        font {
                                            pixelSize: 9
                                            family: "JetBrainsMono Nerd Font"
                                        }
                                        color: Colors.colBlue
                                    }
                                }
                                Text {
                                    visible: modelData.genericName !== ""
                                    text: modelData.genericName
                                    font {
                                        pixelSize: 11
                                        family: "JetBrainsMono Nerd Font"
                                    }
                                    color: Colors.colFg
                                    opacity: 0.35
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
