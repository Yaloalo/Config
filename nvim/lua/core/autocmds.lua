local group = vim.api.nvim_create_augroup('blackhole_core', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = group,
  callback = function() vim.highlight.on_yank({ timeout = 180 }) end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
  pattern = { '*.c', '*.cpp', '*.js', '*.lua', '*.py', '*.ts' },
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(event)
    local buffer = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local map = function(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = buffer, desc = desc })
    end

    map('<leader>ld', vim.lsp.buf.definition, 'LSP definition')
    map('<leader>lr', vim.lsp.buf.references, 'LSP references')
    map('<leader>la', vim.lsp.buf.code_action, 'LSP code action')
    map('<leader>ln', vim.lsp.buf.rename, 'LSP rename')
    map('<leader>lh', vim.lsp.buf.hover, 'LSP hover')

    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, buffer, { autotrigger = true })
    end
  end,
})

