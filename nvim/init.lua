-- init.lua — only 9 lines!

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

require 'core.options' -- vim.opt = { … }
require 'core.keymaps' -- vim.keymap.set(…) calls
require 'core.autocmds' -- any vim.api.nvim_create_autocmd(…) groups
require 'core.plugins' -- bootstrap lazy.nvim & import lua/plugins/*.lua
