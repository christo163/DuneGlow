// Duneglow SDDM theme.
// Landing screen: clock + user pill. Click the pill (or press Enter) to open the password card.
import QtQuick 2.15

Rectangle {
    id: root
    width: 1366
    height: 768
    color: "#161C2E"
    focus: true

    // ---- settings (theme.conf) ---------------------------------------------
    property int forceHour: (typeof config !== "undefined" && config.forceHour !== undefined && config.forceHour !== "") ? parseInt(config.forceHour) : -1
    property string customBg: (typeof config !== "undefined" && config.background !== undefined) ? ("" + config.background) : ""
    property string clockFontFile: (typeof config !== "undefined" && config.clockFontFile !== undefined) ? ("" + config.clockFontFile) : ""

    property string modePref: (typeof config !== "undefined" && config.mode !== undefined && config.mode !== "") ? ("" + config.mode) : "auto"   // auto | light | dark
    property string modeOverride: ""                                  // set by the on-screen toggle
    property bool demo: (typeof config !== "undefined" && config.demo !== undefined && ("" + config.demo) === "true")

    property date now: new Date()
    property int hour: forceHour >= 0 ? forceHour : now.getHours()
    property bool timeNight: hour >= 18 || hour < 6
    property bool night: modeOverride === "dark" ? true : (modeOverride === "light" ? false
                         : (modePref === "dark" ? true : (modePref === "light" ? false : timeNight)))
    property bool customActive: customBg !== "" && bgCustom.status === Image.Ready
    property bool dark: night || customActive

    // ---- palette (dream-tokens.json) ---------------------------------------
    property color textCol:   dark ? "#E7EBF4" : "#262B33"
    property color mutedCol:  dark ? "#9AA7C0" : "#5D6672"
    property color glassCol:  dark ? Qt.rgba(0.15, 0.19, 0.31, 0.62) : Qt.rgba(1, 1, 1, 0.58)   // no-blur fallback
    property color frostCol:  dark ? Qt.rgba(0.12, 0.16, 0.28, 0.34) : Qt.rgba(1, 1, 1, 0.30)   // over real blur
    property color edgeCol:   dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.70)
    property color fieldCol:  dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.70)
    property color accentA:   night ? "#E89A62" : "#F2A15A"
    property color accentB:   night ? "#A86BD0" : "#B05CC8"
    // The clock is a mountain shade from the wallpaper (day: mid ridge, night: slate). Light over a custom picture.
    property color clockCol:  customActive ? Qt.rgba(1, 1, 1, 0.92) : (night ? "#7C93B8" : "#7F95AE")

    // ---- state ---------------------------------------------------------------
    property string userName: ""
    property string userReal: ""
    property string userIcon: ""
    property bool busy: false
    property string message: ""
    property bool showLogin: false

    FontLoader { id: inter;     source: "fonts/Inter-Regular.otf" }
    FontLoader { id: interSB;   source: "fonts/Inter-SemiBold.otf" }
    FontLoader { id: interDisp; source: "fonts/InterDisplay-Bold.otf" }
    FontLoader { id: customFont; source: root.clockFontFile !== "" ? root.clockFontFile : "" }
    property string clockFont: (root.clockFontFile !== "" && customFont.status === FontLoader.Ready) ? customFont.name : interDisp.name
    property string uiFont: inter.status === FontLoader.Ready ? inter.name : "sans-serif"
    property string uiBoldFont: interSB.status === FontLoader.Ready ? interSB.name : uiFont
    property string letter: userReal.length > 0 ? userReal.charAt(0).toUpperCase()
                                                : (userName.length > 0 ? userName.charAt(0).toUpperCase() : "?")
    property string displayName: userReal.length > 0 ? userReal : userName

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.now = new Date()
    }

    property string toast: ""
    function showToast(t) { toast = t; toastTimer.restart() }
    function toggleMode() { modeOverride = night ? "light" : "dark" }

    function activate() {
        showLogin = true
        pw.forceActiveFocus()
    }
    function back() {
        showLogin = false
        busy = false
        pw.text = ""
        message = ""
        root.forceActiveFocus()
    }
    function doLogin() {
        if (busy || userName === "")
            return
        message = ""
        busy = true
        if (demo) {                     // ./test.sh preview: there is no login service, so pretend it failed
            demoTimer.restart()
            return
        }
        watchdog.restart()
        sddm.login(userName, pw.text, sessionModel.lastIndex)
    }
    function failed(text) {
        watchdog.stop()
        demoTimer.stop()
        busy = false
        message = text
        pw.text = ""
        shake.restart()
        pw.forceActiveFocus()
    }

    Timer { id: demoTimer; interval: 600; onTriggered: root.failed("Wrong password. Try again. (preview: nothing is checked)") }
    // If the login service never answers, do not stay on "Signing in..." forever.
    Timer { id: watchdog; interval: 12000; onTriggered: root.failed("No answer from the login service. Try again.") }

    Keys.onPressed: {
        if (!showLogin && event.key !== Qt.Key_Escape && event.key !== Qt.Key_Shift
                && event.key !== Qt.Key_Control && event.key !== Qt.Key_Alt && event.key !== Qt.Key_Meta) {
            activate()
            event.accepted = true
        }
    }

    // ---- background (everything the glass can see) ---------------------------
    Item {
        id: backdrop
        anchors.fill: parent

        Image {
            anchors.fill: parent
            source: root.night ? "assets/wallpaper-night.png" : "assets/wallpaper-day.png"
            fillMode: Image.PreserveAspectCrop
            smooth: true
        }
        // Optional user picture (see set-background.sh), drawn over the default wallpaper.
        Image {
            id: bgCustom
            anchors.fill: parent
            source: root.customBg !== "" ? root.customBg : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: 3840
            smooth: true
            visible: status === Image.Ready
        }
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.22
            visible: bgCustom.status === Image.Ready
        }
    }

    // click outside the card to go back to the landing screen
    MouseArea {
        anchors.fill: parent
        onClicked: if (root.showLogin) root.back()
    }

    // ---- brand (top left) ------------------------------------------------------
    Row {
        x: 36; y: 30
        spacing: 12
        Image {
            width: 36; height: 36
            source: "assets/logo.png"
            smooth: true
            sourceSize.width: 72; sourceSize.height: 72
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Duneglow"
            font.family: root.uiBoldFont
            font.pixelSize: 18
            color: root.customActive ? "#FFFFFF" : root.textCol
        }
    }

    // ---- clock -------------------------------------------------------------------
    Column {
        id: clockBlock
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.17
        spacing: 6
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, "HH:mm")
            font.family: root.clockFont
            font.pixelSize: Math.max(72, root.height * 0.16)
            font.bold: true
            color: root.clockCol
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "ddd d MMMM yyyy")
            font.family: root.uiFont
            font.pixelSize: 16
            color: root.customActive ? Qt.rgba(1, 1, 1, 0.85) : root.mutedCol
        }
    }

    // ---- landing: user pill ------------------------------------------------------
    GlassPanel {
        id: pill
        width: 232
        height: 76
        cornerRadius: 22
        backdrop: backdrop
        tint: root.glassCol
        frostTint: root.frostCol
        edge: root.edgeCol
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - height - 56
        opacity: root.showLogin ? 0 : 1
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        Avatar {
            id: pillAvatar
            size: 48
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            letter: root.letter
            imageSource: root.userIcon
            colA: root.accentA
            colB: root.accentB
            fontFamily: root.uiBoldFont
        }
        Column {
            anchors.left: pillAvatar.right
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
                width: parent.width
                text: root.displayName
                elide: Text.ElideRight
                font.family: root.uiBoldFont
                font.pixelSize: 16
                color: root.textCol
            }
            Text {
                width: parent.width
                text: "Click to sign in"
                elide: Text.ElideRight
                font.family: root.uiFont
                font.pixelSize: 12
                color: root.mutedCol
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activate()
        }
    }

    // ---- login card -------------------------------------------------------------------
    GlassPanel {
        id: card
        width: 380
        height: 312
        cornerRadius: 24
        backdrop: backdrop
        tint: root.glassCol
        frostTint: root.frostCol
        edge: root.edgeCol
        anchors.horizontalCenter: parent.horizontalCenter
        property real restY: Math.max(clockBlock.y + clockBlock.height + 40, parent.height * 0.52)
        y: root.showLogin ? restY : restY + 28
        opacity: root.showLogin ? 1 : 0
        visible: root.showLogin || opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

        // swallow clicks so the background handler does not close the card
        MouseArea { anchors.fill: parent }

        Item {
            id: shakeBox
            width: card.width
            height: card.height
            x: 0

            SequentialAnimation {
                id: shake
                PropertyAnimation { target: shakeBox; property: "x"; to: -14; duration: 55 }
                PropertyAnimation { target: shakeBox; property: "x"; to: 14;  duration: 90 }
                PropertyAnimation { target: shakeBox; property: "x"; to: -9;  duration: 80 }
                PropertyAnimation { target: shakeBox; property: "x"; to: 0;   duration: 55 }
            }

            Avatar {
                id: cardAvatar
                size: 76
                anchors.horizontalCenter: parent.horizontalCenter
                y: 26
                letter: root.letter
                imageSource: root.userIcon
                colA: root.accentA
                colB: root.accentB
                fontFamily: root.uiBoldFont
            }

            Text {
                id: nameText
                anchors.horizontalCenter: parent.horizontalCenter
                y: cardAvatar.y + cardAvatar.height + 12
                text: root.displayName
                font.family: root.uiBoldFont
                font.pixelSize: 20
                color: root.textCol
            }

            Rectangle {
                id: field
                width: parent.width - 56
                height: 46
                radius: 12
                anchors.horizontalCenter: parent.horizontalCenter
                y: nameText.y + nameText.height + 16
                color: root.fieldCol
                border.color: pw.activeFocus ? root.accentA : root.edgeCol
                border.width: pw.activeFocus ? 2 : 1

                TextInput {
                    id: pw
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    font.family: root.uiFont
                    font.pixelSize: 16
                    color: root.textCol
                    clip: true
                    enabled: !root.busy
                    Keys.onReturnPressed: root.doLogin()
                    Keys.onEnterPressed: root.doLogin()
                    Keys.onEscapePressed: root.back()
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    visible: pw.text.length === 0
                    text: "Password"
                    font.family: root.uiFont
                    font.pixelSize: 16
                    color: root.mutedCol
                }
            }

            Rectangle {
                id: signIn
                width: field.width
                height: 44
                radius: 12
                anchors.horizontalCenter: parent.horizontalCenter
                y: field.y + field.height + 12
                opacity: root.busy ? 0.6 : 1.0
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.accentA }
                    GradientStop { position: 1.0; color: root.accentB }
                }
                Text {
                    anchors.centerIn: parent
                    text: root.busy ? "Signing in…" : "Sign in"
                    font.family: root.uiBoldFont
                    font.pixelSize: 16
                    color: "#FFFFFF"
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: !root.busy
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.doLogin()
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: signIn.y + signIn.height + 10
                width: parent.width - 40
                horizontalAlignment: Text.AlignHCenter
                text: root.message
                font.family: root.uiFont
                font.pixelSize: 13
                color: "#D9534F"
                wrapMode: Text.WordWrap
            }
        }
    }

    // ---- bottom right: light/dark toggle and power buttons (round, domed glass) ----------
    Rectangle {
        visible: root.toast !== ""
        anchors.right: orbRow.right
        anchors.bottom: orbRow.top
        anchors.bottomMargin: 38
        width: toastText.width + 28
        height: 34
        radius: 17
        color: root.glassCol
        border.color: root.edgeCol
        border.width: 1
        Text {
            id: toastText
            anchors.centerIn: parent
            text: root.toast
            font.family: root.uiFont
            font.pixelSize: 13
            color: root.textCol
        }
    }
    Timer { id: toastTimer; interval: 2600; onTriggered: root.toast = "" }

    Row {
        id: orbRow
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 40
        anchors.bottomMargin: 34
        spacing: 18

        OrbButton {
            label: root.night ? "Light mode" : "Dark mode"
            iconSource: root.night ? "assets/icons/sun.png" : "assets/icons/moon.png"
            backdrop: backdrop
            fontFamily: root.uiBoldFont
            labelColor: root.customActive ? "#FFFFFF" : root.textCol
            tint: root.glassCol; frostTint: root.frostCol; edge: root.edgeCol
            onActivated: root.toggleMode()
        }
        OrbButton {
            visible: root.demo || sddm.canReboot
            label: "Restart"
            iconSource: "assets/icons/restart.png"
            backdrop: backdrop
            fontFamily: root.uiBoldFont
            labelColor: root.customActive ? "#FFFFFF" : root.textCol
            tint: root.glassCol; frostTint: root.frostCol; edge: root.edgeCol
            onActivated: root.demo ? root.showToast("Preview: this would restart the computer") : sddm.reboot()
        }
        OrbButton {
            visible: root.demo || sddm.canPowerOff
            label: "Shut down"
            iconSource: "assets/icons/power.png"
            backdrop: backdrop
            fontFamily: root.uiBoldFont
            labelColor: root.customActive ? "#FFFFFF" : root.textCol
            tint: root.glassCol; frostTint: root.frostCol; edge: root.edgeCol
            onActivated: root.demo ? root.showToast("Preview: this would shut the computer down") : sddm.powerOff()
        }
    }

    // ---- user model: the last user who logged in ---------------------------------------
    Repeater {
        model: userModel
        delegate: Item {
            width: 0; height: 0
            Component.onCompleted: {
                if (index === userModel.lastIndex || (root.userName === "" && index === 0)) {
                    root.userName = model.name
                    root.userReal = model.realName
                    root.userIcon = model.icon ? model.icon : ""
                }
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.failed("Wrong password. Try again.")
        }
        function onLoginSucceeded() {
            watchdog.stop()
            root.message = ""
        }
    }

    Component.onCompleted: root.forceActiveFocus()
}
