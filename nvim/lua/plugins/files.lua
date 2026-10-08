return {
  'stevearc/oil.nvim',
  cmd = 'Oil',
  keys = { { '<leader>e', '<cmd>Oil<CR>', desc = 'File browser' } },
  opts = {
    default_file_explorer = true,
    skip_confirm_for_simple_edits = true,
    view_options = { show_hidden = true },
    win_options = { signcolumn = 'yes:2', cursorcolumn = false },
  },
}
