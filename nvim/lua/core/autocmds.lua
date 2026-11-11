-- lua/core/autocmds.lua
local api = vim.api

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  group = api.nvim_create_augroup("user_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Trim trailing whitespace on save
api.nvim_create_autocmd("BufWritePre", {
  group = api.nvim_create_augroup("TrimWhitespace", { clear = true }),
  pattern = { "*.c", "*.cpp", "*.py", "*.lua", "*.js" },
  callback = function()
    vim.cmd([[ %s/\s\+$//e ]])
  end,
})

api.nvim_create_autocmd("WinNew", {
  pattern = "*",
  callback = function()
    -- Deferred so sidebars (file tree, outline) have set 'winfixwidth' first
    -- and keep their width.
    vim.schedule(function()
      if vim.fn.winnr('$') == 2 and vim.fn.win_gettype() == "" then
        vim.cmd("wincmd =")
      end
    end)
  end,
})
