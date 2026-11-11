pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd
import QtQuick
import "SessionCommand.js" as SessionCommand

// Login state machine: pilot + session selection, greetd conversation and the
// MAGI vote that plays before the session launches.
Singleton {
    id: root

    // NERV_GREETER_DEMO=1 runs without greetd; the password "eva01" is accepted.
    readonly property bool demo: Quickshell.env("NERV_GREETER_DEMO") === "1"

    property var settings: ({})
    property var users: []
    property int userIndex: 0
    property var sessions: []
    property int sessionIndex: 0
    property string host: "MAGI"
    property string cpu: ""
    property string kernel: ""
    property string memory: ""

    readonly property var user: users[userIndex] ?? { name: settings.user ?? "pilot", gecos: "", shell: "/bin/sh" }
    readonly property var session: sessions[sessionIndex] ?? { name: "Hyprland", exec: "start-hyprland", desktop: "Hyprland" }

    property string password: ""
    // Length shown while the MAGI deliberate (the secret itself is already gone).
    property int held: 0
    // idle | deliberating | prompt | approved | denied
    property string phase: "idle"
    property string prompt: "PASSWORD"
    property string message: ""
    // per MAGI unit: standby | deliberating | approve | deny
    property var votes: ["standby", "standby", "standby"]
    property var logLines: []
    property bool responded: false
    property bool powerArmed: false
    property string powerAction: ""

    signal clearInput()

    function log(text) {
        const t = new Date();
        const stamp = ("0" + t.getHours()).slice(-2) + ":" + ("0" + t.getMinutes()).slice(-2) + ":" + ("0" + t.getSeconds()).slice(-2);
        logLines = logLines.concat([stamp + "  " + text]).slice(-4);
    }
    function setVotes(state) { votes = [state, state, state]; }

    function cycleUser(step) {
        if (phase === "deliberating" || phase === "approved" || users.length < 2) return;
        userIndex = (userIndex + step + users.length) % users.length;
        log("PILOT " + user.name.toUpperCase() + " SELECTED");
    }
    function cycleSession(step) {
        if (phase === "deliberating" || phase === "approved" || sessions.length < 2) return;
        sessionIndex = (sessionIndex + step + sessions.length) % sessions.length;
        log("SESSION " + session.name.toUpperCase());
    }

    function submit() {
        if (phase === "deliberating" || phase === "approved") return;
        if (phase === "prompt") {
            phase = "deliberating";
            held = password.length;
            Greetd.respond(password);
            password = ""; clearInput();
            return;
        }
        phase = "deliberating";
        held = password.length;
        message = "";
        prompt = "PASSWORD";
        setVotes("deliberating");
        log("MAGI DELIBERATING ON PILOT " + user.name.toUpperCase());
        if (demo) { demoTimer.restart(); return; }
        if (Greetd.state !== GreetdState.Inactive) Greetd.cancelSession();
        responded = false;
        Greetd.createSession(user.name);
    }

    function approve() {
        phase = "approved";
        voteTimer.verdict = "approve";
        voteTimer.step = 0;
        voteTimer.interval = 420;
        voteTimer.restart();
    }
    function deny(reason) {
        phase = "denied";
        message = (reason || "AUTHENTICATION FAILED").toUpperCase();
        password = ""; clearInput();
        log("ACCESS DENIED");
        voteTimer.verdict = "deny";
        voteTimer.step = 0;
        voteTimer.interval = 140;
        voteTimer.restart();
        resetTimer.restart();
        if (!demo && Greetd.state !== GreetdState.Inactive) Greetd.cancelSession();
    }

    function launch() {
        log("LAUNCHING " + session.name.toUpperCase());
        if (demo) { console.log("demo launch:", user.name, session.exec); resetTimer.restart(); return; }
        // Go through the pilot's login shell like SDDM does, so .zshenv/.zprofile apply.
        const env = ["XDG_SESSION_TYPE=wayland"];
        if (session.desktop) env.push("XDG_SESSION_DESKTOP=" + session.desktop, "XDG_CURRENT_DESKTOP=" + session.desktop);
        Greetd.launch([SessionCommand.build(user.shell, session.exec)], env, true);
    }

    function power(action) {
        // The preview must never reboot the real machine: F11/F12 just close it.
        if (demo) { Qt.quit(); return; }
        if (powerArmed && powerAction === action) {
            log(action === "reboot" ? "REBOOT" : "POWER OFF");
            Quickshell.execDetached(["systemctl", action]);
            return;
        }
        powerArmed = true;
        powerAction = action;
        message = "PRESS AGAIN TO " + (action === "reboot" ? "REBOOT" : "POWER OFF");
        powerTimer.restart();
    }

    Connections {
        target: Greetd
        enabled: !root.demo
        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (responseRequired) {
                if (!root.responded) {
                    root.responded = true;
                    Greetd.respond(root.password);
                    root.password = ""; root.clearInput();
                } else {
                    // Second factor or similar: show PAM's prompt and wait for input.
                    root.prompt = message.toUpperCase().replace(/:\s*$/, "");
                    root.phase = "prompt";
                    root.setVotes("standby");
                }
            } else if (message) {
                if (error) root.message = message.toUpperCase();
                root.log(message.toUpperCase());
            }
        }
        function onAuthFailure(message) { root.deny(message); }
        function onError(error) { root.deny(error); }
        function onReadyToLaunch() { root.approve(); }
    }

    Timer {
        id: demoTimer
        interval: 900
        onTriggered: root.password === "eva01" ? root.approve() : root.deny("demo: password is eva01")
    }
    // Staggered vote: MELCHIOR, BALTHASAR, CASPER flip one after another.
    Timer {
        id: voteTimer
        property string verdict: "approve"
        property int step: 0
        repeat: true
        onTriggered: {
            const v = root.votes.slice();
            v[step] = verdict;
            root.votes = v;
            step++;
            if (step === 3) {
                stop();
                if (verdict === "approve") { root.log("UNANIMOUS APPROVAL"); launchTimer.restart(); }
            }
        }
    }
    Timer { id: launchTimer; interval: 1100; onTriggered: root.launch() }
    Timer {
        id: resetTimer
        interval: 2600
        onTriggered: { root.phase = "idle"; root.setVotes("standby"); }
    }
    Timer {
        id: powerTimer
        interval: 3000
        onTriggered: { root.powerArmed = false; if (root.message.startsWith("PRESS AGAIN")) root.message = ""; }
    }

    // Demo-only remote control: qs ipc call greeter type eva01 / submit / reset
    IpcHandler {
        target: "greeter"
        enabled: root.demo
        function type(text: string): void { root.password = text; }
        function submit(): void { root.submit(); }
        function reset(): void { root.password = ""; root.phase = "idle"; root.setVotes("standby"); }
    }

    // --- data sources -------------------------------------------------------
    FileView {
        path: Quickshell.shellPath("greeter.json")
        blockLoading: true
        onLoaded: { try { root.settings = JSON.parse(text()); } catch (e) { root.settings = {}; } root.pickDefaults(); }
    }
    FileView {
        path: "/etc/passwd"
        blockLoading: true
        onLoaded: {
            const list = [];
            for (const line of text().split("\n")) {
                const f = line.split(":");
                const uid = Number(f[2]);
                if (f.length < 7 || uid < 1000 || uid >= 60000 || /nologin|false$/.test(f[6])) continue;
                list.push({ name: f[0], gecos: (f[4] || "").split(",")[0], shell: f[6] });
            }
            root.users = list;
            root.pickDefaults();
        }
    }
    FileView { path: "/etc/hostname"; blockLoading: true; onLoaded: root.host = text().trim() || root.host }
    FileView { path: "/proc/sys/kernel/osrelease"; blockLoading: true; onLoaded: root.kernel = text().trim() }
    FileView {
        path: "/proc/meminfo"
        blockLoading: true
        onLoaded: { const m = text().match(/MemTotal:\s+(\d+)/); if (m) root.memory = Math.round(Number(m[1]) / 1048576) + " GB"; }
    }
    FileView {
        path: "/proc/cpuinfo"
        blockLoading: true
        onLoaded: { const m = text().match(/model name\s*:\s*(.+)/); if (m) root.cpu = m[1].replace(/\(R\)|\(TM\)| with .*$/g, "").trim(); }
    }
    Process {
        running: true
        command: ["sh", "-c", "for f in /usr/share/wayland-sessions/*.desktop; do "
            + "grep -qE '^(Hidden|NoDisplay)=true' \"$f\" && continue; "
            + "n=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); e=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2-); "
            + "d=$(grep -m1 '^DesktopNames=' \"$f\" | cut -d= -f2- | cut -d';' -f1); "
            + "printf '%s\\t%s\\t%s\\t%s\\n' \"$(basename \"$f\")\" \"$n\" \"$e\" \"$d\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = [];
                for (const line of text.split("\n")) {
                    const [file, name, exec, desktop] = line.split("\t");
                    if (name && exec) list.push({ file, name, exec, desktop: desktop || "" });
                }
                root.sessions = list;
                root.pickDefaults();
            }
        }
    }
    function pickDefaults() {
        const u = users.findIndex(x => x.name === settings.user);
        if (u >= 0) userIndex = u;
        const s = sessions.findIndex(x => x.file === settings.session || x.name === settings.session);
        if (s >= 0) sessionIndex = s;
    }

    Component.onCompleted: {
        log("MAGI SYSTEM ONLINE");
        log(demo ? "DEMO MODE  /  NO GREETD" : "GREETD LINK ESTABLISHED");
    }
}
