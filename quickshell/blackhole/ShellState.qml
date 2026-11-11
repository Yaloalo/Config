pragma Singleton

import Quickshell
import qs.common

Singleton {
    property string overlay: ""
    property bool barVisible: true
    readonly property bool motionEnabled: !Preferences.starsPaused

    function toggleMotion() {
        Preferences.starsPaused = !Preferences.starsPaused;
        Preferences.save();
    }

    function toggleBar() {
        barVisible = !barVisible;
    }

    function toggle(name) {
        overlay = overlay === name ? "" : name;
    }

    // Switch the whole desktop between "star" and "eva". Quickshell and WezTerm
    // follow the mode file live; Hyprland re-reads it on reload; the root sync
    // service mirrors it to the boot menu, splash and login screen.
    function setMode(mode) {
        Mode.set(mode);
        Quickshell.execDetached(["hyprctl", "reload"]);
    }

    function close() {
        overlay = "";
    }
}
