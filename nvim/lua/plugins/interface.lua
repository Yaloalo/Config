return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      style = 'night',
      transparent = true,
      styles = { sidebars = 'transparent', floats = 'transparent' },
      on_colors = function(colors)
        colors.blue = '#8be9fd'
        colors.magenta = '#b48ef7'
      end,
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme('tokyonight')
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = { theme = 'tokyonight', globalstatus = true, section_separators = '', component_separators = '' },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'diagnostics', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    keys = { { '<leader>?', function() require('which-key').show() end, desc = 'All keymaps' } },
    opts = {
      preset = 'modern',
      spec = { { '<leader>l', group = 'LSP' }, { '<leader>g', group = 'Git' } },
    },
  },
}
