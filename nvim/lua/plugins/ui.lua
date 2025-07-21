-- Enable true-color support
vim.o.termguicolors = true

-- ──────────────────────────────────────────────────────────────────────────────
-- Plugins and UI Appearance
-- ──────────────────────────────────────────────────────────────────────────────

return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        views = {
          cmdline_popup = {
            position = { row = 5, col = "50%" },
            size = { width = 60, height = "auto" },
            border = { style = "rounded", padding = { 0, 1 } },
            win_options = {
              winhighlight = {
                FloatBorder = "NoiceWhiteBorder",
                Normal = "NormalFloat",
              },
            },
          },
          popupmenu = {
            relative = "editor",
            position = { row = 8, col = "50%" },
            size = { width = 60, height = 10 },
            border = { style = "rounded", padding = { 0, 1 } },
            win_options = {
              winhighlight = {
                FloatBorder = "NoiceWhiteBorder",
                Normal = "NormalFloat",
              },
            },
          },
        },
      })

      vim.api.nvim_set_hl(0, "NoiceWhiteBorder", { fg = "#ffffff", bg = "none" })
    end,
  },

  {
    "goolord/alpha-nvim",
    dependencies = { "echasnovski/mini.icons", "nvim-lua/plenary.nvim" },
    config = function()
      require("alpha").setup(require("alpha.themes.theta").config)
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
}
