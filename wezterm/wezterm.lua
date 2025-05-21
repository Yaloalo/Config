local io = require("io")
local os = require("os")
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = {}

-- ── Scrollback→Editor Handler ────────────────────────────────────────────────
wezterm.on("edit-scrollback", function(window, pane)
  local rows = pane:get_dimensions().scrollback_rows
  local text = pane:get_lines_as_text(rows)
  local name = os.tmpname()
  local f = io.open(name, "w+")
  f:write(text)
  f:close()

  window:perform_action(
    act.SpawnCommandInNewWindow({
      args = { os.getenv("EDITOR") or "vim", name },
    }),
    pane
  )

  wezterm.sleep_ms(500)
  os.remove(name)
end)

-- ── Theme Definitions & Switcher ──────────────────────────────────────────────
local themes = {
  normal = { color_scheme = "Tokyo Night", window_background_opacity = 1.0 },
  transparent = { color_scheme = "Tokyo Night", window_background_opacity = 0.7 },
}

local function apply_theme(name, window)
  local t = themes[name]
  if not t then
    wezterm.log_error("Unknown theme: " .. name)
    return
  end
  window:set_config_overrides({
    color_scheme = t.color_scheme,
    window_background_opacity = t.window_background_opacity,
  })
end

wezterm.on("switch-theme", function(window, pane)
  local current = window:effective_config().window_background_opacity
  if current == themes.normal.window_background_opacity then
    apply_theme("transparent", window)
  else
    apply_theme("normal", window)
  end
end)

-- ── Appearance ───────────────────────────────────────────────────────────────
-- Use the patched Nerd Font for all those glyphs!
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 15
config.color_scheme = themes.normal.color_scheme
config.window_background_opacity = themes.normal.window_background_opacity
config.window_padding = { left = "0pt", right = "0pt", top = "0pt", bottom = "0pt" }

-- ── Default shell (Starship init lives in your zshrc) ─────────────────────────
config.default_prog = { "/usr/bin/zsh", "-l" }

-- ── Global Keybindings ────────────────────────────────────────────────────────
config.disable_default_key_bindings = true
config.keys = {
  { key = "R", mods = "CTRL|SHIFT", action = act.EmitEvent("edit-scrollback") },
  { key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  {
    key = "B",
    mods = "CTRL|SHIFT",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "N",
    mods = "CTRL|SHIFT",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },

  { key = "H", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "L", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
  { key = "K", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "J", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
  { key = "H", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "L", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 1 }) },
  { key = "K", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "J", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },

  { key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- theme toggle: Shift+Ctrl+B
  { key = "B", mods = "CTRL|SHIFT", action = act.EmitEvent("switch-theme") },
}

return config
