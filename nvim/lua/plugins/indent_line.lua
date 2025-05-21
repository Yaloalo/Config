-- lua/plugins/indent_line.lua
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    config = function()
      local greys = {
        "GreyShade1",
        "GreyShade2",
        "GreyShade3",
        "GreyShade4",
        "GreyShade5",
        "GreyShade6",
        "GreyShade7",
      }

      -- Register highlight groups on colorscheme change
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "GreyShade1", { fg = "#4E4E4E" })
        vim.api.nvim_set_hl(0, "GreyShade2", { fg = "#5F5F5F" })
        vim.api.nvim_set_hl(0, "GreyShade3", { fg = "#707070" })
        vim.api.nvim_set_hl(0, "GreyShade4", { fg = "#818181" })
        vim.api.nvim_set_hl(0, "GreyShade5", { fg = "#929292" })
        vim.api.nvim_set_hl(0, "GreyShade6", { fg = "#A3A3A3" })
        vim.api.nvim_set_hl(0, "GreyShade7", { fg = "#B4B4B4" })
      end)

      -- Setup indent-blankline with greys
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
          highlight = greys,
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
        },
        exclude = {
          filetypes = { "help", "alpha", "neo-tree", "toggleterm" },
          buftypes = { "terminal" },
        },
      })
    end,
  },
}
