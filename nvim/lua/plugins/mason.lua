-- ~/.config/nvim/lua/plugins/mason.lua
return {
  -- 1) mason.nvim: core installer UI
  {
    "williamboman/mason.nvim",
    opts = {},
  },

  -- 2) mason-lspconfig.nvim: install + single-point LSP setup
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local mlsp = require("mason-lspconfig")
      -- Setup Mason LSP config with handlers directly
      mlsp.setup({
        ensure_installed = {}, -- installs driven by mason-tool-installer
        automatic_installation = false,
        handlers = {
          -- default handler (for all servers)
          function(server_name)
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            local servers = {
              clangd = {},
              pyright = {},
              lua_ls = {
                settings = {
                  Lua = {
                    completion = { callSnippet = "Replace" },
                    diagnostics = { disable = { "missing-fields" } },
                    workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                  },
                },
              },
              bashls = {},
            }
            local opts = vim.tbl_deep_extend(
              "force",
              { capabilities = capabilities },
              servers[server_name] or {}
            )
            require("lspconfig")[server_name].setup(opts)
          end,
        },
      })
    end,
  },

  -- 3) mason-tool-installer.nvim: ensure servers & tools remain installed
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "clangd",
          "pyright",
          "lua_ls",
          "bashls",
          "stylua",
        },
      })
    end,
  },
}
