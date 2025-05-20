-- ~/.config/nvim/lua/plugins/lspconfig.lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,

        -- your floating window (hover) style stays the same
        float = {
          border = "rounded",
          source = "if_many",
        },

        -- keep sign-column icons and underlines
        underline = {
          severity = vim.diagnostic.severity.ERROR,
        },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},

        -- 👉 enable the built-in virtual_text (inline, after the code)
        virtual_text = {
          -- you can tweak these if you like:
          spacing = 2, -- how much space between code and message
          prefix = "●", -- a little bullet (default is '●')
          source = "if_many", -- show the source when there are multiple
        },

        -- make sure the *separate-line* style is disabled
        virtual_lines = false,
      })
    end,
  },
}
