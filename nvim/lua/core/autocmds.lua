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

-- Fortune on start
api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        vim.cmd("silent !fortune | cowsay")
      end)
    end
  end,
})

vim.o.splitright = true

vim.api.nvim_create_autocmd("WinNew", {
  pattern = "*",
  callback = function()
    if vim.fn.winnr('$') == 2 and vim.fn.win_gettype() == "" then
      vim.cmd("wincmd =")
    end
  end,
})



