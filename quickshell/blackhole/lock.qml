//@ pragma Env QS_NO_RELOAD_POPUP=1
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import qs.common

// Session lock. Star mode: blind input over falling stars, no feedback at all.
// Eva mode: NERV console; the MAGI vote on the password, 否決 on failure.
ShellRoot {
    id: root
    property string pending: ""
    property bool submitted: false
    property int typed: 0
    // idle | deliberating | approved | denied
    property string phase: "idle"
    property var votes: ["standby", "standby", "standby"]
    property var logLines: []
    property string host: "MAGI"
    readonly property string lockedAt: Qt.formatTime(new Date(), "HH:mm")
    readonly property bool preview: Quickshell.env("INFINITY_LOCK_PREVIEW") === "1"
    signal clearInput()

    function log(text) { logLines = logLines.concat([Qt.formatTime(new Date(), "HH:mm:ss") + "  " + text]).slice(-4); }
    function submit(value) {
        if (submitted || !value.length) return;
        pending = value; submitted = true;
        phase = "deliberating";
        votes = ["deliberating", "deliberating", "deliberating"];
        log("MAGI DELIBERATING");
        if (!auth.start()) { pending = ""; submitted = false; deny(); }
    }
    function deny() {
        phase = "denied"; typed = 0;
        votes = ["deny", "deny", "deny"];
        log("ACCESS DENIED");
        resetTimer.restart();
    }
    function unlock() { lock.locked = false; Qt.quit(); }

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
            if (result !== PamResult.Success) { root.deny(); return; }
            // Star mode unlocks at once; eva mode lets the vote play out first.
            if (!Mode.eva) { root.unlock(); return; }
            root.phase = "approved";
            voteTimer.step = 0;
            voteTimer.restart();
        }
        onError: { root.pending = ""; root.submitted = false; root.deny(); }
    }
    Timer {
        id: voteTimer
        property int step: 0
        interval: 320
        repeat: true
        onTriggered: {
            const v = root.votes.slice();
            v[step] = "approve";
            root.votes = v;
            if (++step === 3) { stop(); root.log("UNANIMOUS APPROVAL"); unlockTimer.restart(); }
        }
    }
    Timer { id: unlockTimer; interval: 700; onTriggered: root.unlock() }
    Timer {
        id: resetTimer
        interval: 2200
        onTriggered: { root.phase = "idle"; root.votes = ["standby", "standby", "standby"]; }
    }
    FileView { path: "/etc/hostname"; blockLoading: true; onLoaded: root.host = text().trim() || root.host }
    Component.onCompleted: { log("TERMINAL SEALED"); log("PILOT " + (Quickshell.env("USER") || "").toUpperCase() + " ABSENT"); }

    component LockScene: Rectangle {
        anchors.fill: parent; color: "black"
        Loader {
            anchors.fill: parent
            sourceComponent: Mode.eva ? evaFace : starFace
        }
        Component {
            id: starFace
            SpaceField { falling: true; starCount: 500; strength: .65 }
        }
        Component {
            id: evaFace
            EvaConsole {
                phase: root.phase
                votes: root.votes
                typed: root.typed
                logLines: root.logLines
                heading: "TERMINAL SEALED"
                idleKanji: "封鎖"
                idleStatus: "PILOT ABSENT"
                stage: "HOST  " + root.host.toUpperCase() + "   /   SESSION LOCKED"
                rows: [{ n: "1", title: (Quickshell.env("USER") || "pilot").toUpperCase(), sub: "sealed at " + root.lockedAt, key: "" }]
                activeRow: 1
                info: [{ k: "HOST", v: root.host }, { k: "SEALED", v: root.lockedAt }]
                hints: [["ENTER", "AUTHENTICATE"], ["ESC", "CLEAR"]]
            }
        }
        TextInput {
            id: password
            anchors.fill: parent
            opacity: 0
            focus: true
            echoMode: TextInput.NoEcho
            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
            // Keep the block count during the vote; clearing the field must not empty it.
            onTextChanged: if (root.phase === "idle" || root.phase === "denied") root.typed = text.length
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
        implicitWidth: 1280; implicitHeight: 720
        title: "Lock preview (not locked)"
        LockScene { anchors.fill: parent }
    }
    Timer { interval: 6000; running: root.preview; onTriggered: Qt.quit() }
}
