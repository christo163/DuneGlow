/*
 * Duneglow Launcher (Step 5). GPL-3.0-or-later.
 * A button (cube logo) that opens a frosted "home screen": search on top,
 * Recent apps, then all apps grouped by category. Uses KDE's private kicker models
 * (org.kde.plasma.private.kicker), whose types were read from the author's Plasma 6.7.5.
 * Written without a Qt runtime available to the author: UNTESTED.
 */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    toolTipMainText: "Home"
    toolTipSubText: "Apps and search"

    FontLoader { id: fRegular;  source: Qt.resolvedUrl("../fonts/Inter-Regular.otf") }
    FontLoader { id: fSemi;     source: Qt.resolvedUrl("../fonts/Inter-SemiBold.otf") }
    FontLoader { id: fDisplay;  source: Qt.resolvedUrl("../fonts/InterDisplay-Bold.otf") }
    readonly property string uiFont: fRegular.name !== "" ? fRegular.name : Qt.application.font.family

    // Light or dark look. Starts from the clock; the real value comes from ~/.cache/duneglow/mode-state (written by duneglow-mode).
    property bool light: { var h = new Date().getHours(); return h >= 6 && h < 18 }
    readonly property color fg: light ? "#262B33" : "white"
    function fill(a) { return light ? Qt.rgba(1, 1, 1, Math.min(1, a * 3.2)) : Qt.rgba(1, 1, 1, a) }
    function edge(a) { return light ? Qt.rgba(0.20, 0.25, 0.35, 0.22) : Qt.rgba(1, 1, 1, a) }
    function refreshMode() { runner.connectSource("cat \"$HOME/.cache/duneglow/mode-state\" 2>/dev/null") }

    // ---- open / close transition: the panel fades and rises in (320 ms), and fades out before the window is hidden (200 ms) ----
    property real reveal: 0
    property bool closing: false
    function openHome() { home.visible = true }
    function closeHome() { if (!home.visible || closing) return; closing = true; openAnim.stop(); closeAnim.restart() }
    function toggleHome() { if (home.visible) closeHome(); else openHome() }
    NumberAnimation { id: openAnim; target: root; property: "reveal"; to: 1; duration: 320; easing.type: Easing.OutCubic }
    SequentialAnimation {
        id: closeAnim
        NumberAnimation { target: root; property: "reveal"; to: 0; duration: 200; easing.type: Easing.InCubic }
        ScriptAction { script: { home.visible = false; root.closing = false } }
    }
    Plasmoid.onActivated: toggleHome()

    P5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            if (source.indexOf("mode-state") >= 0) {
                var s = String(data["stdout"] || "").trim()
                if (s === "light") root.light = true
                else if (s === "dark") root.light = false
            }
            disconnectSource(source)
        }
    }

    // ---- data models (KDE's own) ----
    Kicker.AppsModel {
        id: appsModel
        appletInterface: root
        flat: false
        sorted: true
        showSeparators: false
        showTopLevelItems: false
        autoPopulate: true
    }
    Kicker.RecentUsageModel {
        id: recentModel
        shownItems: Kicker.RecentUsageModel.OnlyApps
        ordering: Kicker.RecentUsageModel.Recent
    }
    Kicker.RunnerModel {
        id: runnerModel
        appletInterface: root
        runners: ["krunner_services", "krunner_systemsettings", "calculator"]
        query: search.text
    }

    // ---- the button in the dock ----
    // same button for the dock (compact) and for the test window (full)
    compactRepresentation: button
    fullRepresentation: button
    Component {
      id: button
      Item {
        implicitWidth: 48
        implicitHeight: 48
        Layout.minimumWidth: Kirigami.Units.iconSizes.medium
        Layout.minimumHeight: Kirigami.Units.iconSizes.medium
        Image {
            anchors.fill: parent
            anchors.margins: 3
            source: Qt.resolvedUrl("../images/logo.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: btn.containsMouse ? 1 : 0.92
        }
        MouseArea {
            id: btn
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleHome()
        }
      }
    }

    // ---- the full-screen home screen ----
    Kicker.DashboardWindow {
        id: home
        visualParent: root
        backgroundColor: Qt.rgba(0, 0, 0, 0)   // window stays invisible; only the glass panel below is drawn
        keyEventProxy: search
        onKeyEscapePressed: {
            if (search.text !== "") search.text = ""
            else root.closeHome()
        }
        onVisibleChanged: {
            if (visible) { root.refreshMode(); root.closing = false; closeAnim.stop(); root.reveal = 0; openAnim.restart() }
            else { search.text = ""; root.reveal = 0 }
        }

        mainItem: MouseArea {
            id: bg
            anchors.fill: parent
            onClicked: root.closeHome()

            // ---- liquid glass ----
            // Plain glass: no picture inside the panel. You see your own desktop through it (nothing from Duneglow is copied in).

            // centred glass panel
            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: Math.min(1040, bg.width - 120)
                height: Math.min(780, bg.height - 160)
                opacity: root.reveal
                scale: 0.94 + 0.06 * root.reveal
                transform: Translate { y: (1 - root.reveal) * 26 }
                radius: 28
                // Glass level: light slate tint over your live desktop. launcher/set-glass.sh changes it.
                // The dock uses the same recipe (tools/make_theme.py, tint #33405E, 16%).
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: root.light ? Qt.rgba(1, 1, 1, 0.50) : Qt.rgba(0.80, 0.86, 0.95, 0.18) }
                    GradientStop { position: 0.55; color: root.light ? Qt.rgba(0.95, 0.96, 0.98, 0.46) : Qt.rgba(0.40, 0.46, 0.60, 0.26) }
                    GradientStop { position: 1.0; color: root.light ? Qt.rgba(0.88, 0.90, 0.95, 0.52) : Qt.rgba(0.20, 0.22, 0.34, 0.42) }
                }
                border.width: 1
                border.color: root.light ? Qt.rgba(1, 1, 1, 0.65) : Qt.rgba(1, 1, 1, 0.30)

                // warm dune glow along the bottom edge
                Rectangle {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                    anchors.margins: 1
                    height: 110
                    radius: panel.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.rgba(0.96, 0.58, 0.28, 0.16) }
                    }
                }
                // glossy sheen across the top
                Rectangle {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                    anchors.margins: 1
                    height: 120
                    radius: panel.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.16) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                // bright specular edge line on top (fades out toward the corners)
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 2 * panel.radius
                    height: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.75) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                MouseArea { anchors.fill: parent }   // clicks inside the panel do not close it

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 28
                anchors.bottomMargin: 20
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 20

                // search pill
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Math.min(520, panel.width - 80)
                    Layout.preferredHeight: 48
                    radius: 24
                    color: root.fill(0.13)
                    border.width: 1
                    border.color: root.edge(0.28)

                    Kirigami.Icon {
                        id: mag
                        source: "search"
                        width: 20; height: 20
                        isMask: true
                        color: root.fg
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: 0.8
                    }
                    TextInput {
                        id: search
                        anchors.left: mag.right
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.fg
                        selectionColor: root.light ? Qt.rgba(0.37, 0.50, 0.70, 0.35) : Qt.rgba(1, 1, 1, 0.35)
                        font.pixelSize: 17
                        font.family: root.uiFont
                        clip: true
                        focus: true
                        onAccepted: {
                            var m = runnerModel.modelForRow(0)
                            if (m && m.count > 0) { m.trigger(0, "", null); root.closeHome() }
                        }
                        Text {
                            visible: search.text === ""
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Search apps and settings"
                            color: root.light ? Qt.rgba(0.15, 0.17, 0.20, 0.55) : Qt.rgba(1, 1, 1, 0.5)
                            font: search.font
                        }
                    }
                }

                // scrolling content
                Flickable {
                    id: flick
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: content.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    QQC2.ScrollBar.vertical: QQC2.ScrollBar {}

                    Column {
                        id: content
                        width: flick.width - 40
                        x: (flick.width - width) / 2
                        spacing: 26

                        // search results (one block per runner)
                        Repeater {
                            model: search.text !== "" ? runnerModel.count : 0
                            delegate: Section {
                                width: content.width
                                srcModel: runnerModel.modelForRow(index)
                                title: (srcModel && srcModel.description) ? srcModel.description : "Results"
                                fontFamily: root.uiFont
                                light: root.light
                                onLaunched: root.closeHome()
                            }
                        }

                        // home: recent apps
                        Section {
                            width: content.width
                            visible: search.text === "" && count > 0
                            property int count: recentModel.count
                            srcModel: recentModel
                            title: "Recent"
                            fontFamily: root.uiFont
                                light: root.light
                            onLaunched: root.closeHome()
                        }

                        // home: all apps by category
                        Repeater {
                            model: search.text === "" ? appsModel.count : 0
                            delegate: Section {
                                width: content.width
                                srcModel: appsModel.modelForRow(index)
                                title: appsModel.labelForRow(index)
                                fontFamily: root.uiFont
                                light: root.light
                                onLaunched: root.closeHome()
                            }
                        }
                    }
                }

                // power buttons (KDE shows its own confirmation for shut down / restart / log out)
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16
                    Repeater {
                        model: [
                            { icon: "system-lock-screen", tip: "Lock",      cmd: "loginctl lock-session" },
                            { icon: "system-log-out",     tip: "Log out",   cmd: "gdbus call --session --dest org.kde.LogoutPrompt --object-path /LogoutPrompt --method org.kde.LogoutPrompt.promptLogout" },
                            { icon: "system-reboot",      tip: "Restart",   cmd: "gdbus call --session --dest org.kde.LogoutPrompt --object-path /LogoutPrompt --method org.kde.LogoutPrompt.promptReboot" },
                            { icon: "system-shutdown",    tip: "Shut down", cmd: "gdbus call --session --dest org.kde.LogoutPrompt --object-path /LogoutPrompt --method org.kde.LogoutPrompt.promptShutDown" }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            width: 44; height: 44; radius: 22
                            color: root.light ? Qt.rgba(1, 1, 1, pm.pressed ? 0.70 : (pm.containsMouse ? 0.58 : 0.42)) : Qt.rgba(1, 1, 1, pm.pressed ? 0.26 : (pm.containsMouse ? 0.20 : 0.12))
                            border.width: 1
                            border.color: root.edge(0.28)
                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 22; height: 22
                                source: parent.modelData.icon
                                isMask: true
                                color: root.fg
                            }
                            MouseArea {
                                id: pm
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { root.closeHome(); runner.connectSource(parent.modelData.cmd) }
                            }
                            QQC2.ToolTip.visible: pm.containsMouse
                            QQC2.ToolTip.text: modelData.tip
                        }
                    }
                }
            }
            }
        }
    }
}
