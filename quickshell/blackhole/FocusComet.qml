pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

Scope {
    id: root
    property var target: null
    property real progress: 1
    readonly property var geometry: target?.lastIpcObject ?? ({})
    Connections {
        target: Hyprland
        function onActiveToplevelChanged() {
            sweep.stop(); root.progress = 1;
            root.target = Hyprland.activeToplevel;
            Hyprland.refreshToplevels();
            settle.restart();
        }
    }
    Timer {
        // IPC reports final geometry during a window's opening animation.
        // Let that animation settle before drawing on its actual outer border.
        id: settle; interval: 320
        onTriggered: {
            if (root.target && Preferences.focusComet && !Preferences.ecoMode
                    && root.geometry.size && !root.geometry.fullscreen) sweep.restart();
        }
    }
    Timer {
        interval: 32; repeat: true; running: sweep.running
        onTriggered: Hyprland.refreshToplevels()
    }
    NumberAnimation {
        id: sweep; target: root; property: "progress"
        from: 0; to: 1; duration: 1050; easing.type: Easing.Linear
    }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: window
            required property var modelData
            readonly property var monitor: Hyprland.monitorFor(modelData)
            visible: sweep.running && root.target?.monitor === monitor
            screen: modelData; color: "transparent"; exclusiveZone: 0
            anchors { top: true; bottom: true; left: true; right: true }
            WlrLayershell.namespace: "infinity-focus-comet"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: Region {}
            Canvas {
                id: comet
                anchors.fill: parent
                Connections { target: root; function onProgressChanged() { comet.requestPaint(); } }
                onPaint: {
                    const c = getContext("2d"); c.reset();
                    const g = root.geometry;
                    if (!g.at || !g.size || root.progress >= 1) return;
                    const x = g.at[0] - (window.monitor?.x ?? 0) - 1;
                    const y = g.at[1] - (window.monitor?.y ?? 0) - 1;
                    // Hyprland's 2px border sits OUTSIDE the client rectangle.
                    // A 2px stroke centered 1px out never paints inside it.
                    const w = g.size[0] + 2, h = g.size[1] + 2, r = 15;
                    const a = w - 2*r, b = h - 2*r, arc = Math.PI*r/2;
                    const perimeter = 2*a + 2*b + 4*arc;
                    function point(d) {
                        d = (d % perimeter + perimeter) % perimeter;
                        if (d < a) return [x+r+d,y]; d -= a;
                        if (d < arc) { const t = d/r-Math.PI/2; return [x+w-r+r*Math.cos(t),y+r+r*Math.sin(t)]; } d -= arc;
                        if (d < b) return [x+w,y+r+d]; d -= b;
                        if (d < arc) { const t = d/r; return [x+w-r+r*Math.cos(t),y+h-r+r*Math.sin(t)]; } d -= arc;
                        if (d < a) return [x+w-r-d,y+h]; d -= a;
                        if (d < arc) { const t = d/r+Math.PI/2; return [x+r+r*Math.cos(t),y+h-r+r*Math.sin(t)]; } d -= arc;
                        if (d < b) return [x,y+h-r-d]; d -= b;
                        const t = d/r+Math.PI; return [x+r+r*Math.cos(t),y+r+r*Math.sin(t)];
                    }
                    const head = root.progress * perimeter;
                    const tail = Math.min(180, perimeter*.1, head);
                    c.lineCap = "round";
                    for (let i=0; i<60; ++i) {
                        const p = point(head-tail+i*tail/60), q = point(head-tail+(i+1)*tail/60);
                        const alpha = Math.pow(i/60, 1.8) * (1-root.progress);
                        c.strokeStyle = "rgba(255,218,80," + alpha + ")";
                        c.lineWidth = 2; c.beginPath(); c.moveTo(p[0],p[1]); c.lineTo(q[0],q[1]); c.stroke();
                    }
                }
            }
        }
    }
}
