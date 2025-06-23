vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.completeopt = "menu,menuone,noselect"
vim.g.have_nerd_font = true

vim.opt.termguicolors = true

require("core.options") -- vim.opt = { … }
require("core.keymaps") -- vim.keymap.set(…) calls
require("core.autocmds") -- any vim.api.nvim_create_autocmd(…) groups

require("core.plugins") -- bootstrap lazy.nvim & import lua/plugins/*.lua

require("core.live_rg").setup()
