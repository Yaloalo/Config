return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local palette = require("core.palette")

      vim.o.showtabline = 0
      vim.o.laststatus = 3
      vim.o.winbar = ""

      local theme = {
        normal = {
          a = { fg = palette.void, bg = palette.ice, gui = "bold" },
          b = { fg = palette.blue, bg = palette.surface },
          c = { fg = palette.text, bg = palette.void },
        },
        insert = { a = { fg = palette.void, bg = palette.blue, gui = "bold" } },
        visual = { a = { fg = palette.void, bg = palette.cobalt, gui = "bold" } },
        replace = { a = { fg = palette.void, bg = palette.red, gui = "bold" } },
        command = { a = { fg = palette.void, bg = palette.blue, gui = "bold" } },
        inactive = {
          a = { fg = palette.muted, bg = palette.void },
          b = { fg = palette.muted, bg = palette.void },
          c = { fg = palette.muted, bg = palette.void },
        },
      }

      require("lualine").setup({
        options = {
          theme = theme,
          component_separators = { left = "·", right = "·" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
          disabled_filetypes = { statusline = { "alpha" } },
        },
        sections = {
          lualine_a = { { "mode", fmt = function(mode) return mode:sub(1, 3) end } },
          lualine_b = { "branch", "diff" },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ●", readonly = " 󰌾", unnamed = "[No Name]" } },
          },
          lualine_x = { "diagnostics", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "oil", "quickfix" },
      })
    end,
  },
}
