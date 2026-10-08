local lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazy_path) then
  local result = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazy_path,
  })
  if vim.v.shell_error ~= 0 then error('Unable to install lazy.nvim:\n' .. result) end
end

vim.opt.rtp:prepend(lazy_path)

require('lazy').setup({
  { import = 'plugins.interface' },
  { import = 'plugins.search' },
  { import = 'plugins.files' },
  { import = 'plugins.language' },
  { import = 'plugins.format' },
}, {
  change_detection = { notify = false },
  checker = { enabled = not vim.env.NVIM_OFFLINE, notify = false },
  rocks = { enabled = false, hererocks = false },
  ui = { border = 'rounded' },
})
