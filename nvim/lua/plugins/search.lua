return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader><leader>', '<cmd>Telescope find_files hidden=true<CR>', desc = 'Find files' },
    { '<leader>/', '<cmd>Telescope live_grep<CR>', desc = 'Live grep' },
    { '<leader>b', '<cmd>Telescope buffers<CR>', desc = 'Buffers' },
    { '<leader>k', '<cmd>Telescope keymaps<CR>', desc = 'Keymaps' },
    { '<leader>gh', '<cmd>Telescope git_bcommits<CR>', desc = 'File history' },
  },
  opts = {
    defaults = {
      sorting_strategy = 'ascending',
      layout_config = { prompt_position = 'top', width = 0.9, height = 0.85 },
      border = true,
    },
  },
}
