-- ~/.config/nvim/lua/plugins/cmp.lua
return {
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
          -- Confirm with Ctrl-Y
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),

          -- Ctrl-R: toggle completion menu
          ["<C-r>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.close()
            else
              cmp.complete()
            end
          end, { "i", "c" }),

          -- Ctrl-E: close menu if open, else fallback
          ["<C-e>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.close()
            else
              fallback()
            end
          end, { "i", "c" }),

          -- Ctrl-J/K: navigate next/previous in menu
          ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "i", "c" }),
          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "i", "c" }),
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
        experimental = {
          ghost_text = true,  -- enable ghost text
        },
      })

      -- Transparent background + blue border
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    end,
  },



}
