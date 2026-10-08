return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  cmd = 'ConformInfo',
  keys = {
    {
      '<leader>f',
      function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
      desc = 'Format buffer',
    },
  },
  opts = {
    notify_on_error = false,
    formatters_by_ft = {
      lua = { 'stylua' }, python = { 'ruff_format' }, c = { 'clang_format' }, cpp = { 'clang_format' },
      rust = { 'rustfmt' }, sh = { 'shfmt' }, javascript = { 'prettier' },
      javascriptreact = { 'prettier' }, typescript = { 'prettier' }, typescriptreact = { 'prettier' },
      css = { 'prettier' }, html = { 'prettier' }, json = { 'prettier' }, markdown = { 'prettier' },
      svelte = { 'prettier' }, qml = { 'qmlformat' },
    },
  },
}
