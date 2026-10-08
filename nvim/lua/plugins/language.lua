local servers = { 'bashls', 'clangd', 'cssls', 'html', 'jsonls', 'lua_ls', 'pyright', 'qmlls', 'rust_analyzer', 'vtsls' }

return {
  {
    'williamboman/mason.nvim',
    enabled = not vim.env.NVIM_OFFLINE,
    cmd = 'Mason',
    opts = { ui = { border = 'rounded' } },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    enabled = not vim.env.NVIM_OFFLINE,
    dependencies = { 'williamboman/mason.nvim' },
    opts = { ensure_installed = servers, automatic_enable = false },
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { spacing = 3, source = 'if_many' },
        float = { border = 'rounded', source = true },
        signs = true,
        underline = true,
      })

      vim.lsp.config('*', { capabilities = vim.lsp.protocol.make_client_capabilities(), root_markers = { '.git' } })
      vim.lsp.config('lua_ls', { settings = { Lua = { diagnostics = { globals = { 'vim' } } } } })
      vim.lsp.config('qmlls', { cmd = { 'qmlls' } })
      vim.lsp.enable(servers)
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      ensure_installed = { 'bash', 'c', 'cpp', 'css', 'html', 'javascript', 'json', 'lua', 'markdown', 'python', 'query', 'rust', 'typescript', 'vim', 'vimdoc' },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts) require('nvim-treesitter.configs').setup(opts) end,
  },
}
