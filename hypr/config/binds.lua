local mod = "SUPER"
local shell = "qs -c blackhole ipc call shell "

-- Shell and desktop tools.
hl.bind(mod .. " + R", hl.dsp.exec_cmd(shell .. "toggleLauncher"), { description = "App launcher" })
hl.bind(mod .. " + F1", hl.dsp.exec_cmd(shell .. "toggleKeybinds"), { description = "Shortcut atlas" })
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd(shell .. "toggleKeybinds"), { description = "Shortcut atlas" })
hl.bind(mod .. " + I", hl.dsp.exec_cmd(shell .. "togglePower"), { description = "Power menu" })
hl.bind(mod .. " + B", hl.dsp.exec_cmd(shell .. "toggleMotion"), { description = "Pause wallpaper motion" })
hl.bind(mod .. " + M", hl.dsp.exec_cmd("uwsm app -- nwg-displays"), { description = "Arrange displays" })

-- Applications.
hl.bind(mod .. " + T", hl.dsp.exec_cmd("uwsm app -- wezterm"), { description = "Terminal" })
hl.bind(mod .. " + A", hl.dsp.exec_cmd("uwsm app -- wezterm start --always-new-process -- yazi"), { description = "Files" })
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("uwsm app -- firefox"), { description = "Browser" })
hl.bind(mod .. " + N", hl.dsp.exec_cmd("uwsm app -- wezterm start --always-new-process -- nvim"), { description = "Editor" })
hl.bind(mod .. " + P", hl.dsp.exec_cmd("/home/yaloalo/.config/hypr/screenshot-area.sh"), { description = "Area screenshot" })
hl.bind(mod .. " + S", hl.dsp.exec_cmd("/home/yaloalo/.config/scripts/system-info.sh"), { description = "System information" })

-- Window management.
hl.bind(mod .. " + F", hl.dsp.window.close(), { description = "Close window" })
hl.bind(mod .. " + X", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(mod .. " + Y", hl.dsp.window.fullscreen({ mode = 1 }), { description = "Fake fullscreen" })

local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = direction }), { description = "Focus " .. direction })
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = direction }), { description = "Swap " .. direction })
end

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces.
for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace, silent = true }))
end
hl.bind(mod .. " + Q", hl.dsp.focus({ workspace = 11 }), { description = "External workspace" })
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.move({ workspace = 11, silent = true }))
hl.bind(mod .. " + E", hl.dsp.workspace.toggle_special("term"), { description = "Terminal scratchpad" })
hl.bind(mod .. " + SHIFT + E", hl.dsp.window.move({ workspace = "special:term", silent = true }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Hardware keys.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
