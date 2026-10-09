-- lua/core/plugins.lua
-- Bootstraps folke/lazy.nvim and loads all plugin specs in lua/plugins/*

local fn = vim.fn
local lp = fn.stdpath('data') .. '/lazy/lazy.nvim'

-- 1) Clone lazy.nvim if not already installed
if not vim.loop.fs_stat(lp) then
  local result = fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lp,
  }
  if vim.v.shell_error ~= 0 then
    error('Unable to install lazy.nvim:\n' .. result)
  end
end

-- 2) Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lp)

-- 3) Configure and install plugins
require('lazy').setup({
  -- import all plugin-spec files from lua/plugins/*.lua
  { import = 'plugins' },
}, {
  change_detection = { notify = false },
  ui = {
    -- always use Nerd Font icons (no fallback)
    icons = {},
  },
  -- disable luarocks/hererocks support
  rocks = {
    enabled   = false,
    hererocks = false,
  },
})
