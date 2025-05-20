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
        -- <Tab> will accept the current popup item if menu is open,
        -- otherwise fall back to whatever Tab did before.
        ["<Tab>"] = { "accept", "fallback_to_mappings" },
        -- <C-y> will always accept the *first* suggestion (your ghost-text).
        ["<C-y>"] = { "select_and_accept" },
      },

      completion = {
        menu = {
          auto_show = false, -- only show with <C-Space>
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
  },
}
