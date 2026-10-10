//@ pragma Env QS_NO_RELOAD_POPUP=1
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick

ShellRoot {
    id: root
    property string pending: ""
    property bool submitted: false
    readonly property bool preview: Quickshell.env("INFINITY_LOCK_PREVIEW") === "1"
    function submit(value) {
        if (submitted || !value.length) return;
        pending = value; submitted = true;
        if (!auth.start()) { pending = ""; submitted = false; }
    }
    PamContext {
        id: auth
        config: "hyprlock"
        user: Quickshell.env("USER")
        onResponseRequiredChanged: {
            if (responseRequired && root.submitted) {
                respond(root.pending);
                root.pending = "";
            }
        }
        onCompleted: result => {
            root.pending = ""; root.submitted = false;
            if (result === PamResult.Success) { lock.locked = false; Qt.quit(); }
        }
        onError: { root.pending = ""; root.submitted = false; }
    }
    component LockScene: Rectangle {
                anchors.fill: parent; color: "black"
                SpaceField { anchors.fill: parent; falling: true; starCount: 500; strength: .65 }
                TextInput {
                    id: password
                    anchors.fill: parent
                    opacity: 0
                    focus: true
                    echoMode: TextInput.NoEcho
                    inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                    onAccepted: { root.submit(text); text = ""; }
                    Keys.onEscapePressed: text = ""
                    Component.onCompleted: forceActiveFocus()
                }
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.BlankCursor }
    }
    WlSessionLock {
        id: lock
        locked: !root.preview
        WlSessionLockSurface { LockScene { anchors.fill: parent } }
    }
    FloatingWindow {
        visible: root.preview
        implicitWidth: 800; implicitHeight: 500
        title: "Star lock preview (not locked)"
        LockScene { anchors.fill: parent }
    }
    Timer { interval: 4000; running: root.preview; onTriggered: Qt.quit() }
}
