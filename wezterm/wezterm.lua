local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ── Window background ─────────────────────────────────────────────────────────
-- Start fully transparent; Hyprland handles blur/compositing.
config.window_background_opacity = 0.0
config.kde_window_background_blur = false

-- ── Tabs: show tab index + current running process (basename only) ───────────
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

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
config.font_size = 18.0
config.color_scheme = "tokyonight_night"

-- Make the retro tab bar strip transparent, while keeping the scheme's tab colors.
config.colors = {
  tab_bar = {
    -- Transparent strip behind the tabs
    background = "rgba(0,0,0,0)",
    -- We don't touch active_tab/inactive_tab, so the scheme's colors remain.
  },
}

config.window_padding = {
  left = "0pt",
  right = "0pt",
  top = "0pt",
  bottom = "0pt",
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
    -- no need to touch color_scheme here; we keep tokyonight_night
  end

  window:set_config_overrides(ovr)
end)

-- ── Dynamic resize on font-change ────────────────────────────────────────────
config.adjust_window_size_when_changing_font_size = true

-- ── Keybindings ──────────────────────────────────────────────────────────────
config.disable_default_key_bindings = true
config.keys = {
  -- scrollback → editor
  { key = "R", mods = "CTRL|SHIFT", action = act.EmitEvent("edit-scrollback") },

  -- font size
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

  -- direct tab selection: CTRL|SHIFT + number
  { key = "1", mods = "CTRL|SHIFT", action = act.ActivateTab(0) },
  { key = "2", mods = "CTRL|SHIFT", action = act.ActivateTab(1) },
  { key = "3", mods = "CTRL|SHIFT", action = act.ActivateTab(2) },
  { key = "4", mods = "CTRL|SHIFT", action = act.ActivateTab(3) },
  { key = "5", mods = "CTRL|SHIFT", action = act.ActivateTab(4) },
  { key = "6", mods = "CTRL|SHIFT", action = act.ActivateTab(5) },
  { key = "7", mods = "CTRL|SHIFT", action = act.ActivateTab(6) },
  { key = "8", mods = "CTRL|SHIFT", action = act.ActivateTab(7) },
  { key = "9", mods = "CTRL|SHIFT", action = act.ActivateTab(8) },
  -- optional: 0 for 10th tab
  { key = "0", mods = "CTRL|SHIFT", action = act.ActivateTab(9) },

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

