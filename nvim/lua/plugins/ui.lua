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

  -------------------------------------------------------------------------------
  -- Show changes since last save (disk) in the signcolumn
  -------------------------------------------------------------------------------
  {
    "echasnovski/mini.diff",
    version = false,
    event = "BufReadPost",
    config = function()
      local diff = require("mini.diff")

      diff.setup({
        view = {
          -- use line‑number highlighting instead of signs
          style = "number",
          -- you can leave these if you want the gutter signs too (won’t hurt)
          signs = { add = "┃", change = "┃", delete = "┃" },
          priority = 199,
        },
        source = diff.gen_source.save(),
      })

      -- Highlight the numbers themselves:
      -- blue for changed lines
      vim.api.nvim_set_hl(0, "MiniDiffNumberChange", { fg = "#0000ff" })
      -- red for deleted lines
      vim.api.nvim_set_hl(0, "MiniDiffNumberDelete", { fg = "#ff0000" })
      -- (optional) green for added lines
      vim.api.nvim_set_hl(0, "MiniDiffNumberAdd", { fg = "#00ff00" })

      -- Optional keymaps
      local map = vim.keymap.set
      map("n", "<leader>ds", function()
        diff.toggle_overlay()
      end, { desc = "MiniDiff: toggle overlay" })
      map("n", "]h", function()
        diff.goto_hunk("next")
      end, { desc = "MiniDiff: next hunk" })
      map("n", "[h", function()
        diff.goto_hunk("prev")
      end, { desc = "MiniDiff: prev hunk" })

      -- Keep signcolumn to one cell (still useful if you keep signs)
      vim.opt.signcolumn = "yes:1"
    end,
  },
}
