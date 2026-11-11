.pragma library

function quote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'";
}

function build(shell, command) {
    // greetd joins its cmd array with spaces and evaluates it with /bin/sh -c.
    // Preserve the entire inner login-shell command as ONE quoted argument.
    return quote(shell || "/bin/sh") + " -l -c " + quote("exec " + command);
}
