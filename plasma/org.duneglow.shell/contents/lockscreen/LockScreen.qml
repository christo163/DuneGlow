/*
 * Duneglow lock screen. GPL-3.0-or-later.
 * Lives in a shell package (Plasma 6.7: the lock screen is no longer part of Look and Feel).
 * Follows the contract of the stock lock screen in
 *   /usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/
 * Written without a Qt runtime available to the author: preview with plasma/lock.sh test.
 * `authenticator`, `kscreenlocker_userName` are context properties from kscreenlocker.
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // --- properties kscreenlocker / the stock UI contract expects on the root item ---
    property bool debug: false
    property string notification
    signal clearPassword()
    signal notificationRepeated()
    property bool viewVisible: false   // "magical property" the greeter looks for

    implicitWidth: 800
    implicitHeight: 600

    FontLoader { id: fontClock; source: "fonts/InterDisplay-Bold.otf" }
    FontLoader { id: fontSemi;  source: "fonts/Inter-SemiBold.otf" }
    FontLoader { id: fontReg;   source: "fonts/Inter-Regular.otf" }

    // dark 18:00-05:59, same rule as the login theme
    property date now: new Date()
    readonly property bool night: now.getHours() >= 18 || now.getHours() < 6
    // A custom picture (see duneglow-background) is drawn over the built-in wallpaper; text then uses the light-on-dark style.
    Custom { id: custom }
    readonly property bool customActive: customImage.status === Image.Ready
    readonly property bool dark: night || customActive
    readonly property color clockColor: dark ? "#7C93B8" : "#7F95AE"
    readonly property color textColor: dark ? "#EEF2F8" : "#2B3A4F"

    property bool showPrompt: false
    property bool busy: false
    property string pendingPassword: ""
    property string message: ""
    readonly property string userName: (typeof kscreenlocker_userName !== "undefined") ? kscreenlocker_userName : ""

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
        Image {
            id: customImage
            anchors.fill: parent
            source: custom.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready
        }
    }

    // ---- authentication (same flow as the stock lock screen) ----
    // Keeps the PAM backend alive while locked, exactly like the stock heartbeat.
    Timer {
        interval: 1000
        running: !authenticator.unlocked
        repeat: true
        onTriggered: authenticator.startAuthenticating()
    }

    function submit() {
        var pw = passwordField.text
        if (root.busy || pw.length === 0) return
        passwordField.text = ""
        root.message = ""
        if (authenticator.pamTimeout) {
            // backend not ready yet: hold the password and send it when it is
            root.pendingPassword = pw
            root.busy = true
        } else {
            authenticator.respond(pw)
        }
    }

    function showMessage(msg) {
        if (msg && msg.length > 0) root.message = msg
    }

    Connections {
        target: authenticator

        function onPamTimeoutChanged() {
            if (!authenticator.pamTimeout && root.pendingPassword.length > 0) {
                authenticator.respond(root.pendingPassword)
                root.pendingPassword = ""
                root.busy = false
            }
        }
        function onFailed(kind) {
            if (kind != 0) return           // ignore non-interactive authenticators
            root.busy = false
            root.pendingPassword = ""
            root.message = "Wrong password"
            root.clearPassword()
            authenticator.startAuthenticating()
            shake.restart()
            passwordField.forceActiveFocus()
        }
        function onSucceeded() {
            // stops pending authentication processes, preventing timeouts
            authenticator.stopAuthenticating()
            Qt.quit()
        }
        function onInfoMessageChanged()  { root.showMessage(authenticator.infoMessage) }
        function onErrorMessageChanged() { root.showMessage(authenticator.errorMessage) }
        function onPromptChanged()       { root.showMessage(authenticator.prompt) }
        function onPromptForSecretChanged() {
            if (root.showPrompt) passwordField.forceActiveFocus()
        }
    }
    onClearPassword: passwordField.text = ""

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
        width: 400; height: 270
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
            spacing: 12

            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "assets/logo.png"
                sourceSize.width: 96; sourceSize.height: 96
                Layout.preferredWidth: 48; Layout.preferredHeight: 48
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.userName.length > 0 ? root.userName : "Locked"
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
                    color: Qt.rgba(1, 1, 1, root.dark ? 0.10 : 0.40)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, root.dark ? 0.25 : 0.65)
                }
                onAccepted: root.submit()
                Keys.onEscapePressed: {
                    text = ""
                    root.message = ""
                    root.showPrompt = false
                    root.forceActiveFocus()
                }
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
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

    Component.onCompleted: {
        root.viewVisible = true
        root.forceActiveFocus()
        authenticator.startAuthenticating()
    }
}
