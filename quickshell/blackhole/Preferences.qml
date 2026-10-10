pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property bool ecoMode: false
    property bool ecoPauseStars: true
    property bool ecoDisableBlur: true
    property bool ecoDisableAnimations: true
    property int ecoBrightness: 35
    property real starDensity: 1.5
    property real starSpeed: 1
    property bool focusComet: true
    property string status: ""
    readonly property var fields: ["ecoMode", "ecoPauseStars", "ecoDisableBlur", "ecoDisableAnimations", "ecoBrightness", "starDensity", "starSpeed", "focusComet"]
    function save() {
        const data = {};
        for (const name of fields) data[name] = root[name];
        file.setText(JSON.stringify(data, null, 2));
    }
    function applyEco() {
        if (eco.running) return;
        eco.command = ["bash", Quickshell.shellPath("../../scripts/space-eco.sh"), ecoMode ? "on" : "off",
            String(ecoBrightness), ecoDisableBlur ? "1" : "0", ecoDisableAnimations ? "1" : "0"];
        eco.running = true;
        save();
    }
    FileView {
        id: file
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/quickshell/blackhole/preferences.json"
        onLoaded: {
            try {
                const data = JSON.parse(text());
                for (const name of root.fields) if (data[name] !== undefined) root[name] = data[name];
            } catch (error) { root.status = "Preferences could not be read; using defaults."; }
        }
    }
    Process {
        id: eco
        stdout: StdioCollector { onStreamFinished: root.status = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.status = text.trim() }
    }
}
