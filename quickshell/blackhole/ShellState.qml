pragma Singleton

import Quickshell

Singleton {
    property string overlay: ""
    property bool motionEnabled: true

    function toggle(name) {
        overlay = overlay === name ? "" : name;
    }

    function close() {
        overlay = "";
    }
}
