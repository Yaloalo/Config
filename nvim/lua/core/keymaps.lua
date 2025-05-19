-- lua/core/keymaps.lua
local map = vim.keymap.set

-- Clear search highlights
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Quickfix
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic Quickfix' })

-- Window navigation
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move to left window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move to bottom window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move to top window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move to right window' })

-- In insert mode: move cursor with Ctrl+hjkl
map('i', '<C-h>', '<Left>')
map('i', '<C-j>', '<Down>')
map('i', '<C-k>', '<Up>')
map('i', '<C-l>', '<Right>')

--Ranger Autocommand
-- in your lua/core/keymaps.lua (or wherever you centralize mappings):
map(
  'n',
  '<Leader>r',
  '<Cmd>Ranger<CR>',
  { noremap = true, silent = true, desc = "Open Ranger via fm-nvim" }
)
