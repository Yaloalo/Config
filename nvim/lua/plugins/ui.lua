-- Enable true-color support
vim.o.termguicolors = true

-- ──────────────────────────────────────────────────────────────────────────────
-- Plugins and UI Appearance
-- ──────────────────────────────────────────────────────────────────────────────

return {

  {
    "p00f/alabaster.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      -- enable truecolor
      vim.o.termguicolors = true
      vim.g.alabaster_dim_comments = false
      vim.g.alabaster_floatborder = false

      -- your custom palette
      local colors = {
        bg = "#1a1b26",
        comment = "#565f89",
        constant = "#ff9e64",
        string = "#bb9af7",
        global = "#2ac3de",
      }

      local function apply_theme()
        -- 1) load the base Alabaster theme
        vim.cmd("colorscheme alabaster")

        -- 2) override the background for Normal windows & floats
        vim.api.nvim_set_hl(0, "Normal", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = colors.bg })

        -- 3) remap syntax groups to your custom palette
        vim.api.nvim_set_hl(0, "Comment", { fg = colors.comment, bg = colors.bg })
        vim.api.nvim_set_hl(0, "Constant", { fg = colors.constant, bg = colors.bg })
        vim.api.nvim_set_hl(0, "String", { fg = colors.string, bg = colors.bg })
        -- “global” variables in code often use the Identifier group
        vim.api.nvim_set_hl(0, "Identifier", { fg = colors.global, bg = colors.bg })
      end

      -- apply immediately
      apply_theme()
    end,
  },

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
