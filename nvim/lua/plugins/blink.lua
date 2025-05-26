-- ~/.config/nvim/lua/plugins/blink.lua
return {
  -- Core completion engine
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "luasnip" } },
          { { name = "buffer" }, { name = "path" } }
        ),
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
          }),
        },
      })

      -- Transparent background + blue border
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    end,
  },

  -- Blink.cmp for ghost-text
  {
    "saghen/blink.cmp",
    version = "1.*",
    after = "nvim-cmp",
    event = "InsertEnter",
    opts = {
      keymap = {
        ["<C-y>"] = { "select_and_accept" }, -- complete with Ctrl-Y
      },
      completion = {
        menu = { auto_show = false }, -- disable auto popup
        ghost_text = {
          enabled = true, -- always show
          show_with_menu = true,
          show_without_menu = true,
          show_without_selection = true,
        },
      },
      fuzzy = { implementation = "rust" },
      signature = { enabled = false },
    },
    config = function(_, opts)
      require("blink.cmp").setup(opts)

      -- Highlight ghost text clearly
      local function set_ghost_hl()
        vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { link = "Comment", default = true })
      end
      set_ghost_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_ghost_hl })
    end,
  },
}
