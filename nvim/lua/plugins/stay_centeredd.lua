-- ~/.config/nvim/lua/plugins/stay-centered.lua
return {
  "arnamak/stay-centered.nvim",
  lazy = false,
  opts = {
    enabled = true,
    allow_scroll_move = true,
    disable_on_mouse = true,
    skip_filetypes = { "help", "gitcommit", "neo-tree", "TelescopePrompt" },
  },
  keys = {
    { "<leader>t", function() require("stay-centered").toggle() end, desc = "Toggle stay-centered.nvim" },
  },
}

