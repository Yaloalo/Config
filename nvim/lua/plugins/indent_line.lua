-- ~/.config/nvim/lua/plugins/indent_line.lua
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    config = function()
      -- Monochrome greyscale levels
      local grey = {
        "MonoIndent1",
        "MonoIndent2",
        "MonoIndent3",
        "MonoIndent4",
        "MonoIndent5",
        "MonoIndent6",
        "MonoIndent7",
      }

      -- Register highlight groups on colorscheme change
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "MonoIndent1", { fg = "#222222" })
        vim.api.nvim_set_hl(0, "MonoIndent2", { fg = "#333333" })
        vim.api.nvim_set_hl(0, "MonoIndent3", { fg = "#444444" })
        vim.api.nvim_set_hl(0, "MonoIndent4", { fg = "#555555" })
        vim.api.nvim_set_hl(0, "MonoIndent5", { fg = "#666666" })
        vim.api.nvim_set_hl(0, "MonoIndent6", { fg = "#777777" })
        vim.api.nvim_set_hl(0, "MonoIndent7", { fg = "#888888" })
      end)

      require("ibl").setup({
        indent = {
          char      = "│",
          tab_char  = "│",
          highlight = grey,
        },
        scope = {
          enabled    = true,
          show_start = false,
          show_end   = false,
        },
        exclude = {
          filetypes = { "help", "alpha", "neo-tree", "toggleterm" },
          buftypes  = { "terminal" },
        },
      })
    end,
  },
}
