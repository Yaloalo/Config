local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ── Static transparent background; Hyprland will handle blur ─────────────────
config.window_background_opacity = 0.0
config.kde_window_background_blur = false

-- Roman numeral helper (unchanged)
local roman_map = {
  { 1000, "M" },
  { 900, "CM" },
  { 500, "D" },
  { 400, "CD" },
  { 100, "C" },
  { 90, "XC" },
  { 50, "L" },
  { 40, "XL" },
  { 10, "X" },
  { 9, "IX" },
  { 5, "V" },
  { 4, "IV" },
  { 1, "I" },
}
local function to_roman(n)
  local res = ""
  for _, p in ipairs(roman_map) do
    while n >= p[1] do
      res = res .. p[2]
      n = n - p[1]
    end
  end
  return res
end

-- Tabs: simple circles + Roman numerals
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  local sym = tab.is_active and "◉" or "○"
  local title = sym .. to_roman(tab.tab_index + 1)
  return { { Text = " " .. wezterm.truncate_right(title, max_width) .. " " } }
end)

-- Ensure the tab bar itself is transparent too, but with deep purple accents

config.colors = {
  tab_bar = {
    -- entire tab-bar background
    background = "rgba(0,0,0,0)",
    -- active tab
    active_tab = {
      bg_color = "rgba(0,0,0,0)",
      fg_color = "#cba6f7", -- mauve
    },
    -- inactive tabs
    inactive_tab = {
      bg_color = "rgba(0,0,0,0)",
      fg_color = "#6c7086", -- overlay0
    },
    -- hovered inactive tab
    inactive_tab_hover = {
      bg_color = "rgba(0,0,0,0)",
      fg_color = "#7f849c", -- overlay1
    },
    -- the “+” new-tab button
    new_tab = {
      bg_color = "rgba(0,0,0,0)",
      fg_color = "#9399b2", -- overlay2
    },
    new_tab_hover = {
      bg_color = "rgba(0,0,0,0)",
      fg_color = "#b4befe", -- lavender
    },
  },
}

-- Scrollback → editor (unchanged)
wezterm.on("edit-scrollback", function(window, pane)
  local rows = pane:get_dimensions().scrollback_rows
  local text = pane:get_lines_as_text(rows)
  local tmp = os.tmpname()
  local f = io.open(tmp, "w+")
  f:write(text)
  f:close()
  window:perform_action(
    act.SpawnCommandInNewWindow({ args = { os.getenv("EDITOR") or "vim", tmp } }),
    pane
  )
  wezterm.sleep_ms(500)
  os.remove(tmp)
end)

-- Appearance & shell
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 15.0
config.color_scheme = "tokyonight_night"
config.window_padding = { left = "0pt", right = "0pt", top = "0pt", bottom = "0pt" }
config.default_prog = { "/usr/bin/zsh", "-l" }

-- Toggle full transparency ↔ opaque + TokyoNight
local toggle_transparency = wezterm.action_callback(function(window, _)
  local ovr = window:get_config_overrides() or {}
  local cur_opacity = ovr.window_background_opacity or config.window_background_opacity
  if cur_opacity < 0.1 then
    ovr.window_background_opacity = 1.0
    ovr.color_scheme = "tokyonight_night"
  else
    ovr.window_background_opacity = 0.0
  end
  window:set_config_overrides(ovr)
end)

-- Keybindings
config.disable_default_key_bindings = true
config.keys = {
  -- scrollback
  { key = "R", mods = "CTRL|SHIFT", action = act.EmitEvent("edit-scrollback") },
  -- tabs
  { key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  -- splits & pane movement
  { key = "N", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
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
