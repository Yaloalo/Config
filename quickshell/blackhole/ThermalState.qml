pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// CPU temperature + fan speed, polled only while thermal star speed is on.
// heat 0..1 maps to 0.5x..4x desktop star speed (see SpaceField).
Singleton {
    id: root
    property real temp: 0      // °C
    property real fan: 0       // rpm, fastest fan
    property bool hasFan: false
    property bool available: false
    // Calibration: 45 °C / 0 rpm is cool, 85 °C / 5500 rpm is flat out.
    readonly property real heat: {
        const t = Math.max(0, Math.min(1, (temp - 45) / 40));
        const f = Math.max(0, Math.min(1, fan / 5500));
        return hasFan ? t * 0.6 + f * 0.4 : t;
    }

    Timer {
        interval: 3000
        repeat: true
        triggeredOnStart: true
        running: Preferences.thermalSpeed
        onTriggered: if (!poll.running) poll.running = true
    }
    Process {
        id: poll
        // hwmon numbering is not stable across boots, so resolve sensors by name each poll.
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do n=$(cat $h/name); "
            + "case $n in k10temp|coretemp|zenpower) echo T $(cat $h/temp1_input) ;; esac; "
            + "for f in $h/fan*_input; do [ -r \"$f\" ] && echo F $(cat \"$f\" 2>/dev/null); done; done; true"]
        stdout: StdioCollector {
            onStreamFinished: {
                let t = 0, f = 0, fans = false;
                for (const line of text.split("\n")) {
                    const [kind, value] = line.trim().split(" ");
                    const v = Number(value);
                    if (!isFinite(v)) continue;
                    if (kind === "T") t = Math.max(t, v / 1000);
                    else if (kind === "F") { fans = true; f = Math.max(f, v); }
                }
                root.available = t > 0;
                root.temp = t;
                root.fan = f;
                root.hasFan = fans;
            }
        }
    }
}
