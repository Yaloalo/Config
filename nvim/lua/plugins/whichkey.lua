return {

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      win = {
        no_overlap = true,
        padding = { 1, 2 },
        border = "rounded",
        title = true,
        title_pos = "center",
        zindex = 1000,
        wo = { winblend = 0 },
      },
      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = true, suggestions = 20 },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      layout = { width = { min = 20 }, spacing = 3 },
      icons = { breadcrumb = "»", separator = "➜", group = "+", mappings = true },
      spec = {
        { "<leader>s", group = "󰈞  [S]earch" },
        { "<leader>d", group = "  [D]ebug" },
        { "<leader>l", group = "  [L]SP" },
        { "<leader>o", group = "󰏆  [O]il" },
        { "<leader>b", group = "󰎞  [B]ullshit" },
        { "<leader>g", group = "  [G]rug" },
        { "<leader>h", group = "  [H]arpoon" },
        { "<leader>u", group = " [U]ndotree" },
        { "<leader>r", group = "󰍉  [R]ing" },
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      for _, group in ipairs({
        "NormalFloat",
        "FloatBorder",
        "WhichKeyFloat",
        "WhichKeyBorder",
        "WhichKeyNormal",
        "WhichKeyTitle",
        "WinBar",
        "WinBarNC",
        "FloatTitle",
      }) do
        vim.api.nvim_set_hl(0, group, { bg = "none" })
      end
      vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#FFFFFF" })
    end,
  },
}
