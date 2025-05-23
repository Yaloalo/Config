-- ~/.config/nvim/lua/plugins/blink.lua
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "folke/lazydev.nvim",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "accept", "fallback_to_mappings" },
        ["<C-y>"] = { "select_and_accept" },
      },

      completion = {
        menu = {
          auto_show = false,
        },
        ghost_text = {
          enabled = true,
          show_with_menu = false,
          show_without_selection = true,
          show_without_menu = true,
        },
      },

      fuzzy = {
        implementation = "rust",
      },

      signature = { enabled = false },

      sources = {
        default = { "lsp", "path", "snippets", "lazydev", "buffer" },
        providers = {
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },

      appearance = {
        nerd_font_variant = "mono",
      },
    },

    config = function(_, _)
      -- 🔧 Remove InsertCharPre autocommand from blink.cmp to stop <20> echo
      for _, aucmd in ipairs(vim.api.nvim_get_autocmds({ event = "InsertCharPre" })) do
        if aucmd.command and aucmd.command:match("blink/cmp") then
          vim.api.nvim_del_autocmd(aucmd.id)
        end
      end
    end,
  },
}
