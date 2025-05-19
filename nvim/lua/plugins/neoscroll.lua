
-- ~/.config/nvim/lua/plugins/neoscroll.lua
return {
  "karb94/neoscroll.nvim",
  opts = {
    -- Which keys get smooth scrolling
    mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>",
                 "<C-y>", "<C-e>", "zt", "zz", "zb" },
    hide_cursor         = true,   -- hide while animating
    stop_eof            = true,   -- don’t scroll past eof
    respect_scrolloff   = false,  -- ignore scrolloff margin
    cursor_scrolls_alone= true,   -- if window can’t scroll, move cursor
    duration_multiplier = 1.0,    -- global speed multiplier
    easing              = "cubic",-- default easing (see below)
    pre_hook            = nil,
    post_hook           = nil,
    performance_mode    = false,  -- disable performance mode
    ignored_events      = { "WinScrolled", "CursorMoved" },
  },
  config = function(_, opts)
    require("neoscroll").setup(opts)
  end,
}
