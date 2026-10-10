hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})
hl.window_rule({
    name = "float-settings",
    match = { class = "^(nm-connection-editor|nwg-displays|pavucontrol)$" },
    float = true,
    center = true,
    size = "75% 78%",
})

hl.window_rule({
    name = "terminal-scratchpad",
    match = { class = "^(global-term)$" },
    workspace = "special:term silent",
    float = true,
    size = "90% 86%",
    center = true,
})

hl.layer_rule({
    name = "blackhole-shell-blur",
    match = { namespace = "blackhole-shell" },
    blur = true,
    ignore_alpha = 0.08,
})

hl.layer_rule({
    name = "infinity-shell-blur",
    match = { namespace = "infinity-shell" },
    blur = true,
    ignore_alpha = 0.06,
})
