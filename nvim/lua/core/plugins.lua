-- lua/core/plugins.lua
-- Bootstraps folke/lazy.nvim and loads all plugin specs in lua/plugins/*

local fn = vim.fn
local data = fn.stdpath 'data'
local lp = data .. '/lazy/lazy.nvim'

-- 1) Clone lazy.nvim if not already installed
if not vim.loop.fs_stat(lp) then
  fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lp,
  }
end

-- 2) Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lp)

-- 3) Configure and install plugins
require('lazy').setup({
  -- import all plugin-spec files from lua/plugins/*.lua
  { import = 'plugins' },
}, {
  ui = {
    -- use Nerd Font icons if available; otherwise fall back
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '📑',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤',
    },
  },
})
