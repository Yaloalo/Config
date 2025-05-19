-- ~/.config/nvim/lua/plugins/ui.lua
return {
  -- Tokyo Night theme
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",       -- choices: storm, night, day
      transparent = false,
      terminal_colors = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Alpha dashboard
  {
    "goolord/alpha-nvim",
    dependencies = { "echasnovski/mini.icons", "nvim-lua/plenary.nvim" },
    config = function()
      require("alpha").setup(require("alpha.themes.theta").config)
    end,
  },

  -- Lualine with Tokyo Night theme
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local lualine = require("lualine")
      local tokyonight = require("lualine.themes.tokyonight")

      lualine.setup({
        options = {
          icons_enabled        = true,
          theme                = tokyonight,
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          disabled_filetypes   = { statusline = {}, winbar = {} },
          always_divide_middle = true,
          globalstatus         = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_diagnostic" } } },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline         = {},
        winbar          = {},
        inactive_winbar = {},
        extensions      = {},
      })
    end,
  },

  -- TODO comments
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  -- Mini suite
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup { n_lines = 500 }
      require("mini.surround").setup()
      require("mini.statusline").setup { use_icons = vim.g.have_nerd_font }
    end,
  },
}
