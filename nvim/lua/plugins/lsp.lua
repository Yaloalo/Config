-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  -- Telescope for rich pickers (defs/refs/diagnostics/symbols)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = {
          width = 0.95,
          height = 0.9,
          preview_width = 0.6,
          prompt_position = "top",
        },
      },
    },
  },

  -- Core LSP stack
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", build = ":MasonUpdate" },
      "williamboman/mason-lspconfig.nvim",
      -- Optional: augments capabilities if you use nvim-cmp
      "hrsh7th/cmp-nvim-lsp",
      -- Optional: LSP progress UI
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Mason bootstrap (guarded)
      local ok_mason, mason = pcall(require, "mason")
      if not ok_mason then
        vim.notify("[lsp] mason.nvim not found; skipping LSP installer setup", vim.log.levels.WARN)
        return
      end
      local ok_mason_lsp, mason_lsp = pcall(require, "mason-lspconfig")
      if not ok_mason_lsp then
        vim.notify("[lsp] mason-lspconfig.nvim not found; skipping LSP installer setup", vim.log.levels.WARN)
        return
      end

      mason.setup({})
      mason_lsp.setup({
        ensure_installed = {
          -- Web
          "vtsls", "svelte", "html", "cssls", "jsonls",
          "eslint", "emmet_ls", "tailwindcss",
          -- Extras
          "pyright",  -- Python
          "clangd",   -- C/C++
          -- LaTeX
          "texlab",   -- LaTeX LSP (labels/refs/chktex/completion)
          "ltex",     -- Grammar/spell LSP
        },
        automatic_installation = true,
      })

      -- Capabilities (nvim-cmp enhances if present)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp.default_capabilities(capabilities)
      end

      -- Diagnostics: virtual lines by default, one global toggle -> applies to all LSPs incl. LaTeX
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = true,
        severity_sort = true,
        update_in_insert = true,
      })
      vim.g.diagnostics_virtual_lines = true
      vim.keymap.set("n", "<leader>lto", function()
        local new = not vim.g.diagnostics_virtual_lines
        vim.g.diagnostics_virtual_lines = new
        vim.diagnostic.config({
          virtual_lines = new,
          virtual_text = not new,
        })
      end, { desc = "Toggle diagnostics (virtual lines/text)" })

      -- Reusable Telescope opts for LSP pickers (two-pane w/ preview on right)
      local TLAY = {
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = {
          width = 0.95,
          height = 0.9,
          preview_width = 0.6,
          prompt_position = "top",
        },
        fname_width = 60,
        results_title = false,
      }

      local lspconfig = require("lspconfig")
      local tb = require("telescope.builtin")

      -- Helper wrappers to enforce our layout + sensible defaults
      local function defs()  tb.lsp_definitions(TLAY) end
      local function impls() tb.lsp_implementations(TLAY) end
      local function tdefs() tb.lsp_type_definitions(TLAY) end
      local function refs()
        local opts = vim.tbl_extend("force", TLAY, { include_declaration = false, show_line = true })
        tb.lsp_references(opts)
      end
      local function type_usages()  refs() end   -- cursor on type
      local function symbol_usages() refs() end  -- cursor on symbol

      -- General on_attach: keymaps + inlay hints + disable server formatting
      local function on_attach(client, bufnr)
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Telescope-powered LSP navigation/search (all behind <leader>l…)
        map("<leader>ld", defs,                         "LSP: Definitions")
        map("<leader>lI", impls,                        "LSP: Implementations")
        map("<leader>ly", tdefs,                        "LSP: Type Definitions")
        map("<leader>lR", refs,                         "LSP: References")
        map("<leader>lD", function() tb.diagnostics(TLAY) end,           "Diagnostics (Telescope)")
        map("<leader>ls", function() tb.lsp_document_symbols(TLAY) end,  "Document Symbols")
        map("<leader>lS", function() tb.lsp_workspace_symbols(TLAY) end, "Workspace Symbols")

        -- “usage” searches
        map("<leader>lT", type_usages,                  "Type usages (cursor on type)")
        map("<leader>lU", symbol_usages,                "Symbol usages (cursor on id)")

        -- Core LSP actions
        map("<leader>lh", vim.lsp.buf.hover,            "Hover")
        map("<leader>ln", vim.lsp.buf.rename,           "Rename")
        map("<leader>la", vim.lsp.buf.code_action,      "Code Action")

        -- Diagnostics navigation
        map("<leader>lpn", vim.diagnostic.goto_next,    "Next Diagnostic")
        map("<leader>lpp", vim.diagnostic.goto_prev,    "Prev Diagnostic")
        map("<leader>lll", vim.diagnostic.open_float,   "Line Diagnostics")

        -- Prefer external formatters (Conform/Prettier/Black/clang-format/latexindent via Conform if you add it)
        local disable_fmt = {
          vtsls = true, tsserver = true, svelte = true, html = true, cssls = true,
          jsonls = true, tailwindcss = true, eslint = true, pyright = true, clangd = true,
          texlab = true, ltex = true,
        }
        if disable_fmt[client.name] then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end

        -- Inlay hints (Neovim 0.10+)
        if vim.lsp.inlay_hint then
          if type(vim.lsp.inlay_hint.enable) == "function" then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          else
            pcall(vim.lsp.inlay_hint, bufnr, true)
          end
        end
      end

      -- JavaScript / TypeScript via vtsls
      lspconfig.vtsls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          typescript = {
            format = { enable = false },
            inlayHints = {
              includeInlayParameterNameHints = "literals",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            preferences = { importModuleSpecifierPreference = "non-relative" },
          },
          javascript = {
            format = { enable = false },
            inlayHints = {
              includeInlayParameterNameHints = "literals",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      -- Svelte
      lspconfig.svelte.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          svelte = {
            plugin = {
              svelte = { format = { enable = false } }, -- Prettier handles it
              typescript = { diagnostics = { enable = true } },
            },
          },
        },
      })

      -- HTML / CSS / JSON / ESLint / Emmet / Tailwind
      lspconfig.html.setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig.cssls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = { css = { validate = true }, less = { validate = true }, scss = { validate = true } },
      })
      lspconfig.jsonls.setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig.eslint.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = { format = false, workingDirectory = { mode = "auto" } },
      })
      lspconfig.emmet_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "html", "css", "scss", "less", "javascriptreact", "typescriptreact", "svelte" },
      })
      lspconfig.tailwindcss.setup({ on_attach = on_attach, capabilities = capabilities })

      -- Python (Pyright)
      lspconfig.pyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              inlayHints = {
                variableTypes = true,
                functionReturnTypes = true,
                callArgumentNames = "literals",
                genericTypes = true,
              },
            },
          },
        },
      })

      -- C/C++ (clangd)
      lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
        },
      })

      -- LaTeX (texlab) — Overleaf-like symbols/labels/diag
      lspconfig.texlab.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          texlab = {
            build = { onSave = false, forwardSearchAfter = false }, -- VimTeX handles build/view
            forwardSearch = { executable = "" }, -- viewer handled by VimTeX
            chktex = { onOpenAndSave = true, onEdit = false },      -- lint on open/save
            diagnosticsDelay = 300,
            bibtexFormatter = "texlab",
            latexFormatter = "latexindent", -- keep off (formatting disabled above)
            latexindent = { modifyLineBreaks = true },
          },
        },
      })

      -- Grammar/Spell (LTeX) — optional heavy but useful
      lspconfig.ltex.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "tex", "plaintex", "bib", "markdown" },
        settings = {
          ltex = {
            language = "en-GB",
            -- additionalLanguages = { "de-DE" },
            -- dictionary = { ["en-GB"] = { "Neovim", "VimTeX" } },
            -- disabledRules = { ["en-GB"] = { "MORFOLOGIK_RULE_EN_GB" } },
          },
        },
      })
    end,
  },
}
