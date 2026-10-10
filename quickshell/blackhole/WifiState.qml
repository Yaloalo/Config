pragma Singleton
import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root
    property var selected: null
    property var attempt: null
    property bool autoConnect: true
    property bool askPassword: false
    property string message: ""
    property var policyNetwork: null
    property bool policyValue: true
    property var policyProfile: null
    property int policyTicks: 0
    readonly property bool busy: attempt?.stateChanging ?? false
    readonly property bool personal: [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae].includes(selected?.security ?? WifiSecurityType.Unknown)
    readonly property bool openNetwork: [WifiSecurityType.Open, WifiSecurityType.Owe].includes(selected?.security ?? WifiSecurityType.Unknown)
    readonly property bool advanced: Boolean(selected && !selected.known && !personal && !openNetwork)

    function select(network) {
        if (busy || policyNetwork) return;
        selected = network;
        message = "";
        askPassword = !network.known && !openNetwork;
        autoConnect = network.nmSettings.length ? (network.nmSettings[0].read().connection?.autoconnect ?? true) : true;
    }
    function savePolicy(network, enabled) {
        policyNetwork = network; policyValue = enabled;
        policyProfile = null; policyTicks = 0;
        policyTimer.restart();
        applyPolicy();
    }
    function applyPolicy() {
        if (!policyNetwork) return;
        if (!policyProfile && policyNetwork.nmSettings.length) {
            policyProfile = policyNetwork.nmSettings[0];
            policyProfile.write({connection: {autoconnect: policyValue}});
        }
        if (policyProfile && (policyProfile.read().connection?.autoconnect ?? true) === policyValue) {
            policyNetwork = null; policyProfile = null; policyTimer.stop();
        }
    }
    function connect(password) {
        if (!selected || busy || advanced) return;
        if (askPassword && !((password.length >= 8 && password.length <= 63) || /^[a-fA-F0-9]{64}$/.test(password))) {
            message = "Enter 8–63 characters, or a 64-digit hexadecimal key."; return;
        }
        attempt = selected;
        message = "Connecting…";
        // Keep policy tracking alive even if the user closes the menu.
        savePolicy(attempt, autoConnect);
        if (askPassword) attempt.connectWithPsk(password);
        else if (attempt.nmSettings.length) attempt.connectWithSettings(attempt.nmSettings[0]);
        else attempt.connect();
    }
    Connections {
        target: root.attempt
        function onConnectedChanged() {
            if (root.attempt?.connected) { root.message = "Connected"; root.askPassword = false; root.applyPolicy(); }
        }
        function onNmSettingsChanged() { root.applyPolicy(); }
        function onConnectionFailed(reason) {
            root.message = "Connection failed: " + ConnectionFailReason.toString(reason) + ". Try again.";
            if (root.personal) root.askPassword = true;
            root.policyNetwork = null; root.policyProfile = null; policyTimer.stop();
        }
    }
    Timer {
        id: policyTimer; interval: 500; repeat: true
        onTriggered: {
            root.applyPolicy();
            if (++root.policyTicks > 40 && root.policyNetwork) {
                root.message = "Could not confirm automatic connection setting. Check Network connections.";
                root.policyNetwork = null; root.policyProfile = null; stop();
            }
        }
    }
}
