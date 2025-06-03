-- ~/.config/nvim/lua/plugins/indent_line.lua
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    config = function()
      -- Use Tokyo Night palette for indent colors
      local tokyo = {
        "TNIndent1",
        "TNIndent2",
        "TNIndent3",
        "TNIndent4",
        "TNIndent5",
        "TNIndent6",
        "TNIndent7",
      }

      -- Register highlight groups on colorscheme change
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        -- Level 1: blue
        vim.api.nvim_set_hl(0, "TNIndent1", { fg = "#7aa2f7" })
        -- Level 2: green
        vim.api.nvim_set_hl(0, "TNIndent2", { fg = "#9ece6a" })
        -- Level 3: purple
        vim.api.nvim_set_hl(0, "TNIndent3", { fg = "#bb9af7" })
        -- Level 4: yellow
        vim.api.nvim_set_hl(0, "TNIndent4", { fg = "#e0af68" })
        -- Level 5: red
        vim.api.nvim_set_hl(0, "TNIndent5", { fg = "#f7768e" })
        -- Level 6: aqua/teal
        vim.api.nvim_set_hl(0, "TNIndent6", { fg = "#2ac3de" })
        -- Level 7: orange
        vim.api.nvim_set_hl(0, "TNIndent7", { fg = "#ff9e64" })
      end)

      -- Setup indent-blankline with Tokyo Night colors
      --   and perforated current-scope lines (no start/end)
      require("ibl").setup({
        indent = {
          char      = "│",
          tab_char  = "│",
          highlight = tokyo,
        },
        scope = {
          enabled    = true,
          show_start = false,  -- omit the top line of the current scope
          show_end   = false,  -- omit the bottom line of the current scope
        },
        exclude = {
          filetypes = { "help", "alpha", "neo-tree", "toggleterm" },
          buftypes  = { "terminal" },
        },
      })
    end,
  },
}
