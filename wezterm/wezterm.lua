local wezterm = require("wezterm")
local io = require("io")
local os = require("os")
local act = wezterm.action
local config = wezterm.config_builder()
local mux = wezterm.mux
local config = {}

-- ── Scrollback→Editor Handler ────────────────────────────────────────────────
-- this registers an event that grabs the entire scrollback, writes it to
-- a tempfile, and opens $EDITOR (vim/nvim/code --wait/etc) on it
wezterm.on("edit-scrollback", function(window, pane)
	-- number of rows in scrollback
	local rows = pane:get_dimensions().scrollback_rows
	local text = pane:get_lines_as_text(rows)

	-- write to temp file
	local name = os.tmpname()
	local f = io.open(name, "w+")
	f:write(text)
	f:close()

	-- spawn editor in a new window
	window:perform_action(
		act.SpawnCommandInNewWindow({
			args = { os.getenv("EDITOR") or "vim", name },
		}),
		pane
	)

	-- cleanup after a brief pause
	wezterm.sleep_ms(500)
	os.remove(name)
end)

-- ── Appearance ───────────────────────────────────────────────────────────────
config.font = wezterm.font("JetBrains Mono")
config.font_size = 15
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 1
config.window_padding = {
	left = "5pt",
	right = "5pt",
	top = "0pt",
	bottom = "0pt",
}
-- --- Full Screen Startup ------------------------------------------------------
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():toggle_maximized()
end)
-- ── Default shell ─────────────────────────────────────────────────────────────
config.default_prog = { "/usr/bin/zsh", "-l" }

-- ── Global Keybindings ────────────────────────────────────────────────────────
config.disable_default_key_bindings = true
config.keys = {
	-- open scrollback in editor
	{
		key = "R",
		mods = "CTRL|SHIFT",
		action = act.EmitEvent("edit-scrollback"),
	},

	-- tabs & splits
	{ key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "B", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "N", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- pane nav & resize
	{ key = "H", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "L", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "K", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "J", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
	{ key = "H", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "L", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 1 }) },
	{ key = "K", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "J", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },

	-- copy & paste in NORMAL mode
	{ key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
}

--[[ ── COPY MODE & SEARCH MODE ─────────────────────────────────────────────────
config.key_tables = {
	copy_mode = {
		-- start a Vim-style regex search
		{ key = "/", mods = "NONE", action = act.CopyMode("EditPattern") },
		{ key = "c", mods = "NONE", action = act.CopyMode("ClearPattern") },
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
		{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
		{ key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
		{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
		{ key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
		{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "Escape", mods = "NONE", action = act.CopyMode("ClearSelectionMode") },
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({
				act.CopyTo("ClipboardAndPrimarySelection"),
				act.CopyMode("ClearSelectionMode"),
				act.CopyMode("Close"),
			}),
		},
		{ key = "Escape", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
		{ key = "c", mods = "CTRL", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
		{ key = "q", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
	},

	search_mode = {
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "q", mods = "CTRL", action = act.CopyMode("Close") },
		{ key = "f", mods = "CTRL", action = act.CopyMode("EditPattern") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "n", mods = "CTRL|SHIFT", action = act.CopyMode("PriorMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("NextMatchPage") },
	},
}
]]
return config
