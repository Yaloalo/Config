-- Keep the laptop as the safe default; nwg-displays may replace these mappings.
for workspace = 1, 10 do
    hl.workspace_rule({
        workspace = tostring(workspace),
        monitor = "eDP-1",
    })
end

hl.workspace_rule({
    workspace = "11",
    monitor = "HDMI-A-1",
})
