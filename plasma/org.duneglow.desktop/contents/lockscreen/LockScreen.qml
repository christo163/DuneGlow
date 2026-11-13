/*
 * Duneglow lock screen (opt-in). GPL-3.0-or-later.
 * Written without a Qt runtime available to the author: test with
 *   kscreenlocker_greet --testing   before enabling (see plasma/lock.sh).
 * `authenticator` is supplied by kscreenlocker (context property).
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    FontLoader { id: fontClock; source: "fonts/InterDisplay-Bold.otf" }
    FontLoader { id: fontSemi;  source: "fonts/Inter-SemiBold.otf" }
    FontLoader { id: fontReg;   source: "fonts/Inter-Regular.otf" }

    // dark 18:00-05:59, same rule as the login theme
    property date now: new Date()
    readonly property bool night: now.getHours() >= 18 || now.getHours() < 6
    readonly property color clockColor: night ? "#7C93B8" : "#7F95AE"
    readonly property color textColor: night ? "#EEF2F8" : "#2B3A4F"

    property bool showPrompt: false
    property bool busy: false
    property string pendingPassword: ""
    property string message: ""

    property int interfaceVersion: (typeof org_kde_plasma_screenlocker_greeter_interfaceVersion !== "undefined")
                                   ? org_kde_plasma_screenlocker_greeter_interfaceVersion : 0

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.now = new Date()
    }

    // ---- backdrop (also the source for the glass blur) ----
    Item {
        id: backdrop
        anchors.fill: parent
        Image {
            anchors.fill: parent
            source: root.night ? "assets/wallpaper-night.jpg" : "assets/wallpaper-day.jpg"
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    // ---- authentication ----
    Timer {
        id: respondTimer
        interval: 60   // short deferral: responding too early can hit "no pending prompt"
        onTriggered: {
            if (root.pendingPassword.length > 0) {
                var pw = root.pendingPassword
                root.pendingPassword = ""
                authenticator.respond(pw)
            }
        }
    }

    function tryUnlock() {
        if (root.busy || passwordField.text.length === 0) return
        root.busy = true
        root.message = ""
        root.pendingPassword = passwordField.text
        passwordField.text = ""
        authenticator.startAuthenticating()
    }

    Connections {
        target: authenticator
        function onPromptForSecretChanged() {
            if (authenticator.promptForSecret && root.pendingPassword.length > 0)
                respondTimer.restart()
        }
        function onInfoMessageChanged() { if (authenticator.infoMessage) root.message = authenticator.infoMessage }
        function onErrorMessageChanged() { if (authenticator.errorMessage) root.message = authenticator.errorMessage }
        function onFailed() {
            root.busy = false
            root.pendingPassword = ""
            root.message = "Wrong password"
            shake.restart()
            passwordField.forceActiveFocus()
        }
        function onSucceeded() { root.busy = false }
    }

    // ---- stage 1: clock and date ----
    ColumnLayout {
        id: landing
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.16
        spacing: 4
        opacity: root.showPrompt ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 220 } }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(root.now, "hh:mm")
            color: root.clockColor
            font.family: fontClock.name
            font.pixelSize: Math.round(root.height * 0.19)
        }
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(root.now, "dddd, d MMMM")
            color: root.clockColor
            font.family: fontSemi.name
            font.pixelSize: Math.round(root.height * 0.03)
        }
    }

    GlassPanel {
        id: hint
        backdrop: backdrop
        cornerRadius: 22
        width: hintLabel.implicitWidth + 56
        height: 44
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - 120
        opacity: root.showPrompt ? 0.0 : 1.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 220 } }
        Label {
            id: hintLabel
            anchors.centerIn: parent
            text: "Press any key to unlock"
            color: root.textColor
            font.family: fontReg.name
            font.pixelSize: 15
        }
    }

    // ---- stage 2: password card ----
    GlassPanel {
        id: card
        backdrop: backdrop
        cornerRadius: 28
        width: 400; height: 250
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        visible: opacity > 0
        opacity: root.showPrompt ? 1.0 : 0.0
        scale: root.showPrompt ? 1.0 : 0.96
        Behavior on opacity { NumberAnimation { duration: 220 } }
        Behavior on scale { NumberAnimation { duration: 220 } }

        SequentialAnimation {
            id: shake
            NumberAnimation { target: card; property: "x"; to: (root.width - card.width) / 2 - 12; duration: 50 }
            NumberAnimation { target: card; property: "x"; to: (root.width - card.width) / 2 + 12; duration: 80 }
            NumberAnimation { target: card; property: "x"; to: (root.width - card.width) / 2; duration: 50 }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 14

            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "assets/logo.png"
                sourceSize.width: 64; sourceSize.height: 64
                Layout.preferredWidth: 48; Layout.preferredHeight: 48
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Locked"
                color: root.textColor
                font.family: fontSemi.name
                font.pixelSize: 18
            }
            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                echoMode: TextInput.Password
                placeholderText: "Password"
                enabled: !root.busy
                horizontalAlignment: TextInput.AlignHCenter
                color: root.textColor
                font.family: fontReg.name
                font.pixelSize: 16
                background: Rectangle {
                    radius: 22
                    color: Qt.rgba(1, 1, 1, root.night ? 0.10 : 0.40)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, root.night ? 0.25 : 0.65)
                }
                onAccepted: root.tryUnlock()
                Keys.onEscapePressed: {
                    text = ""
                    root.message = ""
                    root.showPrompt = false
                    root.forceActiveFocus()
                }
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.message
                color: "#D9533F"
                font.family: fontReg.name
                font.pixelSize: 14
                visible: text.length > 0
            }
            Item { Layout.fillHeight: true }
        }
    }

    // ---- input ----
    focus: true
    Keys.onPressed: function(event) {
        if (!root.showPrompt) {
            root.showPrompt = true
            passwordField.forceActiveFocus()
            if (event.text.length > 0 && event.key !== Qt.Key_Escape
                    && event.key !== Qt.Key_Return && event.key !== Qt.Key_Enter)
                passwordField.text = event.text
            event.accepted = true
        }
    }
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            root.showPrompt = !root.showPrompt
            if (root.showPrompt) passwordField.forceActiveFocus()
            else root.forceActiveFocus()
        }
    }

    Component.onCompleted: root.forceActiveFocus()
}
