-- lua/core/autocmds.lua
local api = vim.api

-- Highlight on yank
api.nvim_create_autocmd('TextYankPost', {
	group = api.nvim_create_augroup('user_yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- (You can add other global autocmds here, e.g. LSP‐attach hooks or filetype commands.)
