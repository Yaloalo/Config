local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ── Static opaque background by default; Hyprland will handle blur when toggled ─────────────────
config.window_background_opacity = 1.0
config.kde_window_background_blur = false

-- ── Tabs: show current running process (basename only) in each pane ───────────────────────────────
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  -- Get full process path (e.g. "/usr/bin/nvim")
  local full = tab.active_pane.foreground_process_name or "?"
  -- Extract basename ("nvim")
  local proc = full:match("([^/]+)$") or full
  -- Truncate so it never exceeds the tab width
  local title = wezterm.truncate_right(proc, max_width)
  return { { Text = " " .. title .. " " } }
end)

-- Ask if kill process
config.window_close_confirmation = "NeverPrompt"

-- ── Scrollback → editor ─────────────────────────────────────────────────────────────────────────
wezterm.on("edit-scrollback", function(window, pane)
  local rows = pane:get_dimensions().scrollback_rows
  local text = pane:get_lines_as_text(rows)
  local tmp = os.tmpname()
  local f = io.open(tmp, "w+")
  f:write(text)
  f:close()
  window:perform_action(
    act.SpawnCommandInNewWindow({ args = { os.getenv("EDITOR") or "nvim", tmp } }),
    pane
  )
  wezterm.sleep_ms(500)
  os.remove(tmp)
end)

-- ── Appearance & shell ─────────────────────────────────────────────────────────────────────────
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 18.0
config.color_scheme = "tokyonight_night"
config.window_padding = {
  left = "0pt",
  right = "0pt",
  top = "0pt",
  bottom = "0pt",
}
config.default_prog = { "/usr/bin/zsh", "-l" }

-- ── Toggle opaque ↔ transparent + retain TokyoNight scheme on opaque ─────────────────────────────
local toggle_transparency = wezterm.action_callback(function(window, _)
  local ovr = window:get_config_overrides() or {}
  local cur = ovr.window_background_opacity or config.window_background_opacity
  if cur > 0.9 then
    ovr.window_background_opacity = 0.0
  else
    ovr.window_background_opacity = 1.0
    ovr.color_scheme = "tokyonight_night"
  end
  window:set_config_overrides(ovr)
end)

-- ── dynamic resize on font-change ─────────────────────────────────────
config.adjust_window_size_when_changing_font_size = true

-- ── Keybindings ─────────────────────────────────────────────────────────────────────────────────
config.disable_default_key_bindings = true
config.keys = {
  -- scrollback
  { key = "R", mods = "CTRL|SHIFT", action = act.EmitEvent("edit-scrollback") },

  { key = "(", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
  { key = ")", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
  { key = "=", mods = "CTRL|SHIFT", action = act.ResetFontSize },

  -- tabs
  { key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "CTRL", action = act.MoveTabRelative(1) },
  { key = "LeftArrow", mods = "CTRL", action = act.MoveTabRelative(-1) },
  { key = "F", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },

  -- splits & pane movement
  {
    key = "N",
    mods = "CTRL|SHIFT",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "M",
    mods = "CTRL|SHIFT",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  { key = "H", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "L", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
  { key = "K", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "J", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
  { key = "H", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "L", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 1 }) },
  { key = "K", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "J", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },

  -- copy/paste
  { key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- toggle transparency
  { key = "B", mods = "CTRL|SHIFT", action = toggle_transparency },
}

return config
