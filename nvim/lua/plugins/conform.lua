-- lua/plugins/conform.lua
return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        desc = 'Format buffer',
      },
      {
        '<leader>tf',
        function()
          vim.b.disable_autoformat = not vim.b.disable_autoformat
        end,
        desc = 'Toggle autoformat',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat then
          return
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        rust = { 'rustfmt' },
      },
    },
  },
}
