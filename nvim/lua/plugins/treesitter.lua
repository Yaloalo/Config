-- lua/plugins/treesitter.lua
return {
  -- core nvim-treesitter plugin
  {
    'nvim-treesitter/nvim-treesitter',
    version = false,       -- always use latest
    build   = ':TSUpdate',
    dependencies = {
      -- rainbow-delimiters.nvim (uses its own setup API, not the old ts-module system)
      {
        'HiPhish/rainbow-delimiters.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
          -- 1) Pure defaults: just remove this `config` block entirely, and
          --    the plugin will auto-attach its default query & global strategy.

          -- 2) If you want to *explicitly* set strategy/query names:
          require('rainbow-delimiters.setup').setup {
            -- these must be *strings* pointing at the actual modules,
            -- exactly as in the plugin’s `lua/rainbow-delimiters/strategy/*.lua`
            strategy = {
              -- '' (empty key) = default for *all* filetypes
              [''] = 'rainbow-delimiters.strategy.global',
              -- you could override per-filetype here, e.g.:
              -- lua = 'rainbow-delimiters.strategy.local',
            },
            -- by default it uses the bundled `lua/rainbow-delimiters/queries/rainbow-delimiters.scm`
            -- you can override per-filetype if you like:
            -- query = {
            --   [''] = 'rainbow-delimiters',
            --   markdown = 'rainbow-blocks',
            -- },
            -- and you can supply custom highlight-group order if you wish:
            -- highlight = {
            --   'RainbowDelimiterRed',
            --   'RainbowDelimiterYellow',
            --   'RainbowDelimiterBlue',
            --   -- …
            -- },
          }
        end,
      },

      'nvim-treesitter/playground',               -- interactive query inspector
      'nvim-treesitter/nvim-treesitter-textobjects', -- textobjects (select/move)
    },
    opts = {
      -- 1) Parsers to install
      ensure_installed = {
        'bash', 'c', 'lua', 'python', 'javascript',
        'typescript', 'html', 'css', 'markdown', 'vim', 'query',
      },
      sync_install   = false,
      auto_install   = true,

      -- 2) Highlight & indent
      highlight = {
        enable                            = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable  = true,
        disable = { 'python' },
      },

      -- 3) Incremental selection (gnn/grn/grc/grm)
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = 'gnn',
          node_incremental  = 'grn',
          scope_incremental = 'grc',
          node_decremental  = 'grm',
        },
      },

      -- 4) Textobjects: select/move between functions & classes
      textobjects = {
        select = {
          enable    = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable          = true,
          set_jumps       = true,  -- update jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
        },
      },

      -- 5) Playground: inspect treesitter queries in real time
      playground = {
        enable          = true,
        updatetime      = 25,
        persist_queries = false,
      },

      -- 6) Rainbow parentheses/colors
      -- Nothing here: the standalone plugin takes care of itself
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- treesitter-context (show current function/class at top of window)
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPost',
    config = function()
      require('treesitter-context').setup {
        enable     = true,
        max_lines  = 5,
        trim_scope = 'outer',
        patterns = {
          default = {
            'class',
            'function',
            'method',
            'for',
            'while',
            'if',
            'switch',
            'case',
          },
        },
      }
    end,
  },
}
