import QtQuick
Canvas {
    id: root
    property string kind: "wifi"
    property color color: "white"
    property real level: 1
    onKindChanged: requestPaint()
    onColorChanged: requestPaint()
    onLevelChanged: requestPaint()
    onPaint: {
        const c = getContext("2d");
        c.reset(); c.scale(width / 24, height / 24);
        c.strokeStyle = color; c.fillStyle = color; c.lineWidth = 1.5; c.lineCap = "round"; c.lineJoin = "round";
        if (kind === "wifi") {
            for (let r of [5, 9, 13]) { c.beginPath(); c.arc(12, 20, r, -Math.PI * .75, -Math.PI * .25); c.stroke(); }
            c.beginPath(); c.arc(12, 20, 1.2, 0, 7); c.fill();
        } else if (kind === "battery") {
            c.strokeRect(2, 6, 18, 12); c.fillRect(21, 10, 2, 4);
            c.fillRect(4, 8, 14 * Math.max(0, Math.min(1, level)), 8);
        } else if (kind === "settings") {
            for (let x of [5, 12, 19]) { c.beginPath(); c.moveTo(x, 3); c.lineTo(x, 21); c.stroke(); }
            for (let p of [[5, 8], [12, 16], [19, 6]]) { c.fillRect(p[0] - 3, p[1] - 2, 6, 4); }
        } else {
            c.beginPath(); c.moveTo(3, 9); c.lineTo(7, 9); c.lineTo(12, 5); c.lineTo(12, 19); c.lineTo(7, 15); c.lineTo(3, 15); c.closePath(); c.stroke();
            if (kind === "muted") { c.beginPath(); c.moveTo(16, 9); c.lineTo(22, 15); c.moveTo(22, 9); c.lineTo(16, 15); c.stroke(); }
            else for (let r of [5, 9]) { c.beginPath(); c.arc(12, 12, r, -.7, .7); c.stroke(); }
        }
    }
}
