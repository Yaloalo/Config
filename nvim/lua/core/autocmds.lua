-- lua/core/autocmds.lua
local api = vim.api

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  group = api.nvim_create_augroup("user_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto reload nvim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  callback = function()
    if vim.fn.mode() ~= "c" then -- don’t interrupt during command-line
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("TrimWhitespace", { clear = true }),
  pattern = { "*.c", "*.cpp", "*.py", "*.lua", "*.js" },
  callback = function()
    vim.cmd([[ %s/\s\+$//e ]])
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        vim.cmd("silent !fortune | cowsay")
      end)
    end
  end,
})
