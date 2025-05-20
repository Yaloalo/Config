-- ~/.config/nvim/lua/plugins/trouble.lua
return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle", "TroubleRefresh", "TroubleClose" },
    keys = {
      {
        "<leader>ld",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = " Toggle Diagnostics (Trouble)",
      },
    },
    opts = {
      -- how Trouble’s window should look & behave
      position = "bottom", -- bottom / top / left / right
      height = 10, -- only for top/bottom
      width = 50, -- only for left/right
      auto_open = false, -- open when diagnostics are published
      auto_close = false, -- close when there are no more items
      auto_preview = true, -- preview location under cursor
      signs = true, -- show LSP sign column icons
      indent_lines = true, -- add indent guide below fold icons
      group = true, -- group results by file
      padding = true, -- add a blank line at the top
      cycle_results = false, -- cycle back to top when navigating past bottom
      use_diagnostic_signs = true, -- get your gutter icons from your LSP
    },
  },
}
