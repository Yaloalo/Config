pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import qs.common

// One login surface: keyboard handling plus the face for the current mode.
// All outputs share Auth state; only the primary one takes input.
Item {
    id: root
    property bool primary: false
    // 0 pilot, 1 session, 2 password
    property int row: 2

    Loader {
        anchors.fill: parent
        sourceComponent: Mode.eva ? evaFace : starFace
    }
    Component {
        id: starFace
        StarLogin { row: root.row }
    }
    Component {
        id: evaFace
        EvaConsole {
            phase: Auth.phase
            votes: Auth.votes
            typed: Auth.phase === "deliberating" ? Auth.held : Auth.password.length
            message: Auth.message
            logLines: Auth.logLines
            activeRow: root.row
            rows: [
                { n: "1", title: Auth.user.name.toUpperCase(), sub: Auth.user.gecos || "pilot", key: "F2" },
                { n: "2", title: Auth.session.name.toUpperCase(), sub: Auth.session.exec, key: "F3" }
            ]
            stage: "HOST  " + Auth.host.toUpperCase() + "   /   STAGE 3  LOGIN"
            promptLabel: Auth.phase === "prompt" ? Auth.prompt : "PASSWORD"
            info: [
                { k: "CPU", v: Auth.cpu },
                { k: "KERNEL", v: Auth.kernel + (Auth.memory ? "   /   " + Auth.memory : "") },
                { k: "SESSION", v: Auth.session.file ?? "" }
            ]
            hints: [["ENTER", "AUTHENTICATE"], ["↑ ↓", "SELECT"], ["F2", "PILOT"], ["F3", "SESSION"], ["ESC", "CLEAR"], ["F11", "REBOOT"], ["F12", "POWER OFF"]]
        }
    }

    TextInput {
        id: input
        // Must stay visible to hold focus; opacity 0 keeps it off screen.
        opacity: 0
        width: 1
        height: 1
        enabled: root.primary
        focus: root.primary
        echoMode: TextInput.Password
        onTextChanged: if (Auth.phase !== "deliberating" && Auth.phase !== "approved") Auth.password = text
        Connections { target: Auth; function onClearInput() { input.text = ""; } }
        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Return:
            case Qt.Key_Enter: Auth.submit(); break;
            case Qt.Key_Up: root.row = (root.row + 2) % 3; break;
            case Qt.Key_Down:
            case Qt.Key_Tab: root.row = (root.row + 1) % 3; break;
            case Qt.Key_Left: if (root.row === 0) Auth.cycleUser(-1); else if (root.row === 1) Auth.cycleSession(-1); break;
            case Qt.Key_Right: if (root.row === 0) Auth.cycleUser(1); else if (root.row === 1) Auth.cycleSession(1); break;
            case Qt.Key_F2: Auth.cycleUser(1); break;
            case Qt.Key_F3: Auth.cycleSession(1); break;
            case Qt.Key_Escape: input.text = ""; Auth.message = ""; break;
            case Qt.Key_F11: Auth.power("reboot"); break;
            case Qt.Key_F12: Auth.power("poweroff"); break;
            default:
                // Typing always goes to the password field.
                if (event.text.length > 0) root.row = 2;
                return;
            }
            event.accepted = true;
        }
    }
}
