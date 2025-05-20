-- ~/.config/nvim/lua/plugins/conform.lua
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = false,

      -- disable on-save formatting for C/C++
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "c" or ft == "cpp" then
          return nil
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,

      -- completely override the built-in stylua formatter:
      formatters = {
        stylua = {
          inherit = false, -- don’t merge with the default one
          command = "stylua",
          args = {
            "--config-path",
            "/dev/null", -- ← force an empty config
            "--stdin-filepath",
            "$FILENAME", -- map stdin back to real path
            "--indent-type",
            "Spaces",
            "--indent-width",
            "2",
            "--column-width",
            "100",
            "--sort-requires", -- valid substitute for reorder_imports
            "-", -- read from stdin
          },
          stdin = true,
        },
      },

      -- flat list, no nesting:
      formatters_by_ft = {
        lua = { "stylua" },
        -- python = { 'isort', 'black' },
      },
    },
  },
}
