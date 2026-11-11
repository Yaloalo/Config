local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ── Window background ─────────────────────────────────────────────────────────
-- Start fully transparent; Hyprland handles blur/compositing.
config.window_background_opacity = 0.0

-- ── Tabs: show tab index + current running process (basename only) ───────────
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 24

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  -- Full process path (e.g. "/usr/bin/nvim")
  local full = tab.active_pane.foreground_process_name or "?"
  -- Basename ("nvim")
  local proc = full:match("([^/]+)$") or full

  -- tab_index is 0-based; display 1-based
  local index = tab.tab_index + 1
  local title = string.format("%d: %s", index, proc)

  -- Truncate so it fits in the tab width
  title = wezterm.truncate_right(title, max_width)

  return { { Text = " " .. title .. " " } }
end)

-- Don't ask on window close
config.window_close_confirmation = "NeverPrompt"

-- ── Scrollback → editor ──────────────────────────────────────────────────────
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

-- ── Appearance & shell ───────────────────────────────────────────────────────
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13.0
-- Star or eva palette, from the desktop mode file shared with Quickshell and
-- Hyprland. WezTerm reloads by itself when the settings toggle rewrites it.
local mode_file = (os.getenv("XDG_STATE_HOME") or (wezterm.home_dir .. "/.local/state")) .. "/desktop-mode"
wezterm.add_to_config_reload_watch_list(mode_file)
local function desktop_mode()
  local file = io.open(mode_file)
  if not file then return "star" end
  local mode = file:read("*l")
  file:close()
  return mode == "eva" and "eva" or "star"
end

local palettes = {
  star = {
    foreground = "#f7fbff",
    background = "#000000",
    cursor_bg = "#dff8ff",
    cursor_fg = "#010207",
    cursor_border = "#58baff",
    selection_fg = "#f7fbff",
    selection_bg = "#30435e",
    ansi = { "#010207", "#ff607c", "#79c99e", "#e8d79c", "#58baff", "#6685ff", "#9eeaff", "#dce7f2" },
    brights = { "#30435e", "#ff89a0", "#a0ddb8", "#f5e9b8", "#8dd1ff", "#91a6ff", "#dff8ff", "#ffffff" },
    tab_bar = {
      background = "rgba(0,0,0,0)",
      active_tab = { bg_color = "#dff8ff", fg_color = "#010207", intensity = "Bold" },
      inactive_tab = { bg_color = "#0a0f19", fg_color = "#8190a5" },
      inactive_tab_hover = { bg_color = "#111a2a", fg_color = "#f7fbff" },
      new_tab = { bg_color = "#0a0f19", fg_color = "#58baff" },
      new_tab_hover = { bg_color = "#111a2a", fg_color = "#f7fbff" },
    },
  },
  -- NERV terminal: nerv-boot's orange/amber/red/green plus Unit-01 purple.
  eva = {
    foreground = "#fff1e2",
    background = "#000000",
    cursor_bg = "#ff7e1a",
    cursor_fg = "#000000",
    cursor_border = "#ff7e1a",
    selection_fg = "#fff1e2",
    selection_bg = "#5c2508",
    ansi = { "#0a0402", "#f0141e", "#3ce07c", "#ff7e1a", "#e8a33c", "#9a6cff", "#ffb36b", "#fff1e2" },
    brights = { "#5c2508", "#ff4a52", "#7cf0a6", "#ffa04d", "#ffc278", "#b894ff", "#ffd2a0", "#ffffff" },
    tab_bar = {
      background = "rgba(0,0,0,0)",
      active_tab = { bg_color = "#ff7e1a", fg_color = "#000000", intensity = "Bold" },
      inactive_tab = { bg_color = "#1a0b04", fg_color = "#b35a12" },
      inactive_tab_hover = { bg_color = "#2e1406", fg_color = "#fff1e2" },
      new_tab = { bg_color = "#1a0b04", fg_color = "#ff7e1a" },
      new_tab_hover = { bg_color = "#2e1406", fg_color = "#fff1e2" },
    },
  },
}
config.colors = palettes[desktop_mode()]

config.window_padding = {
  left = "3pt",
  right = "3pt",
  top = "2pt",
  bottom = "2pt",
}

config.default_prog = { "/usr/bin/zsh", "-l" }

-- ── Toggle opaque ↔ transparent, keeping color scheme ────────────────────────
local toggle_transparency = wezterm.action_callback(function(window, _)
  local ovr = window:get_config_overrides() or {}
  local cur = ovr.window_background_opacity or config.window_background_opacity

  if cur > 0.9 then
    -- currently opaque → go transparent
    ovr.window_background_opacity = 0.0
  else
    -- currently transparent → go opaque
    ovr.window_background_opacity = 1.0
  end

  window:set_config_overrides(ovr)
end)

-- ── Dynamic resize on font-change ────────────────────────────────────────────
config.adjust_window_size_when_changing_font_size = true

-- ── Keybindings ──────────────────────────────────────────────────────────────
config.disable_default_key_bindings = true
config.keys = {
  -- Restore familiar bindings; newer non-conflicting shortcuts remain aliases.
  { key = "R", mods = "CTRL|SHIFT", action = act.EmitEvent("edit-scrollback") },
  { key = "(", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
  { key = ")", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
  { key = "=", mods = "CTRL|SHIFT", action = act.ResetFontSize },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "CTRL", action = act.MoveTabRelative(1) },
  { key = "LeftArrow", mods = "CTRL", action = act.MoveTabRelative(-1) },
  { key = "F", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "N", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "M", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "B", mods = "CTRL|SHIFT", action = toggle_transparency },
  { key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "W", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "PageDown", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "PageUp", mods = "CTRL", action = act.ActivateTabRelative(-1) },
  { key = "PageDown", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },
  { key = "PageUp", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },
  { key = "S", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "D", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "H", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "J", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
  { key = "K", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "L", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
  { key = "H", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "J", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },
  { key = "K", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "L", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 1 }) },
  { key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "F", mods = "CTRL|SHIFT|ALT", action = act.Search({ CaseInSensitiveString = "" }) },
  { key = "P", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
  { key = "E", mods = "CTRL|SHIFT", action = act.EmitEvent("edit-scrollback") },
  { key = "O", mods = "CTRL|SHIFT", action = toggle_transparency },
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
}
for index = 1, 10 do
  table.insert(config.keys, {key = tostring(index % 10), mods = "CTRL|SHIFT", action = act.ActivateTab(index - 1)})
end

return config
