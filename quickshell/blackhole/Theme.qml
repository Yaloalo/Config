pragma Singleton

import Quickshell
import QtQuick
import qs.common

// Desktop palette for both modes. Star: black glass, white stars, rounded.
// Eva: NERV terminal (nerv-boot palette), square corners, Barlow Condensed.
Singleton {
    readonly property bool eva: Mode.eva
    function pick(star, nerv) { return eva ? nerv : star; }

    readonly property color voidBlack: "#000000"
    readonly property color panel: pick("#a6000000", "#b8000000")
    readonly property color surface: pick("#c0000000", "#cc000000")
    readonly property color surfaceHigh: pick("#dd000000", "#e6060200")
    readonly property color outline: pick("#505050", Nerv.line)
    readonly property color text: pick("#f7fbff", Nerv.white)
    readonly property color muted: pick("#8190a5", Nerv.amber)
    readonly property color ice: pick("#ffffff", Nerv.orange)
    readonly property color blue: pick("#dddddd", Nerv.orange)
    readonly property color blueSoft: pick("#30ffffff", "#40ff7e1a")
    readonly property color cobalt: pick("#376dff", Nerv.red)
    readonly property color comet: pick("#ffd76a", Nerv.green)
    readonly property color warning: pick("#e8d79c", Nerv.orange)
    readonly property color danger: pick("#ff607c", Nerv.red)

    // Former hard-coded greys in the bar, settings and Wi-Fi pages.
    readonly property color fg: pick("white", Nerv.white)
    readonly property color onFg: pick("black", Nerv.void_)      // text on an fg-filled chip
    readonly property color glass: pick("#b0000000", "#c4000000")
    readonly property color glassHover: pick("#d8000000", "#e0140700")
    readonly property color glassDown: pick("#ee000000", "#f0200a00")
    readonly property color edge: pick("#444444", Nerv.line)      // quiet border
    readonly property color edgeMid: pick("#777777", Nerv.amber)  // neutral border, disabled text
    readonly property color edgeHi: pick("#aaaaaa", Nerv.orange)  // hover / checked border
    readonly property color fill: pick("#303030", "#3a1a08")      // checked switch, pressed
    readonly property color knobOff: pick("#666666", Nerv.line)
    readonly property color accentFill: pick("#cccccc", Nerv.orange)
    readonly property color placeholder: pick("#888888", Nerv.amber)
    readonly property color scrim: pick("#78000105", "#a0000000")

    readonly property string font: pick("JetBrainsMono Nerd Font", Nerv.sans)
    readonly property int weight: pick(Font.Normal, Font.DemiBold)
    // Barlow Condensed is narrow, so eva sizes run larger; eva corners are square.
    function fs(px) { return Math.round(px * (eva ? 1.3 : 1)); }
    function r(px) { return eva ? 0 : px; }
}
