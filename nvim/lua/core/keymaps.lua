local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('v', '<C-c>', '<Esc>', { desc = 'Leave visual mode' })
map('n', '<C-n>', '<cmd>split<CR>', { desc = 'Horizontal split' })
map('n', '<C-m>', '<cmd>vsplit<CR>', { desc = 'Vertical split' })

for key, direction in pairs({ h = 'h', j = 'j', k = 'k', l = 'l' }) do
  map('n', '<C-' .. key .. '>', '<C-w><C-' .. direction .. '>', { desc = 'Focus ' .. direction })
end

map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics list' })
map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Write file' })
