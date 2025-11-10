return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        mapping = {}, -- keep it minimal (no insert-mode keybinds)
        sources = { { name = "nvim_lsp" } },
        snippet = { expand = function(_) end }, -- no snippet engine
      }
    end,
    config = function(_, opts)
      require("cmp").setup(opts)
    end,
  },
}

