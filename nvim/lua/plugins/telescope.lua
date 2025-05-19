-- lua/plugins/telescope.lua
return {
  {
    'nvim-telescope/telescope.nvim',
    tag          = '0.1.8',   -- use a stable release
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond  = function() return vim.fn.executable 'make' == 1 end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          -- Use ripgrep, show hidden files
          vimgrep_arguments = {
            'rg', '--color=never', '--no-heading', '--with-filename',
            '--line-number', '--column', '--smart-case', '--hidden',
          },
          prompt_prefix      = '🔍 ',
          selection_caret    = '➤ ',
          entry_prefix       = '  ',
          initial_mode       = 'insert',
          layout_strategy    = 'horizontal',
          layout_config = {
            horizontal = {
              preview_width = 0.6,
            },
            vertical = {
              preview_height = 0.5,
            },
            width  = 0.9,
            height = 0.8,
            preview_cutoff = 120,
          },
          borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
          file_ignore_patterns = { 'node_modules', '.git/' },
          mappings = {
            i = {
              ['<C-c>'] = require('telescope.actions').close,
              ['<C-j>'] = require('telescope.actions').move_selection_next,
              ['<C-k>'] = require('telescope.actions').move_selection_previous,
            },
            n = {
              ['q']     = require('telescope.actions').close,
              ['<CR>']  = require('telescope.actions').select_default,
            },
          },
        },
        pickers = {
          find_files = {
            hidden      = true,          -- show dotfiles
            no_ignore   = true,          -- don’t respect .gitignore
          },
          live_grep = {
            only_sort_text = true,
          },
        },
        extensions = {
          ['ui-select'] = require('telescope.themes').get_dropdown({}),
        },
      }

      -- load extensions                    
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')

      -- keymaps
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files,  { desc = '  Find Files' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep,   { desc = '  Live Grep' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin,     { desc = '  Telescope' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags,   { desc = '  Help Tags' })
      vim.keymap.set('n', '<leader>sn', function()           -- search your neovim config
        builtin.find_files { cwd = vim.fn.stdpath 'config', prompt_title = '~ Config ~' }
      end, { desc = '  Search Neovim Config' })

      -- extras
      vim.keymap.set('n', '<leader>sb', builtin.buffers,     { desc = '﬘  Open Buffers' })
      vim.keymap.set('n', '<leader>so', builtin.oldfiles,     { desc = '  Recent Files' })
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys     = vim.g.have_nerd_font and {} or {
          Up='<Up>', Down='<Down>', Left='<Left>', Right='<Right>',
          C='<C-…>', M='<M-…>',  D='<D-…>',   S='<S-…>',
          CR='<CR>', Esc='<Esc>', Space='<Space>', Tab='<Tab>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>c', group = '[C]ode'   },
        { '<leader>g', group = '[G]it'    },
      },
    },
  },
}
