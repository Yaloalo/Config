-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      -- Treesitter extensions
      "nvim-treesitter/playground",
      "nvim-treesitter/nvim-treesitter-textobjects",
      -- Replace p00f/nvim-ts-rainbow with HiPhish’s rainbow-delimiters.nvim
      "HiPhish/rainbow-delimiters.nvim",
    },
    config = function()
      -- Treesitter core setup
      require("nvim-treesitter.configs").setup {
        -- Parsers to install
        ensure_installed = {
          "bash", "c", "lua", "python", "javascript",
          "typescript", "html", "css", "markdown",
          "vim", "query", "latex", "rust"
        },
        sync_install = false,
        auto_install = true,

        -- Core highlighting
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        -- Indentation
        indent = {
          enable = true,
          disable = { "python" },
        },

        -- Incremental selection
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection    = "gnn",
            node_incremental  = "grn",
            scope_incremental = "grc",
            node_decremental  = "grm",
          },
        },

        -- Text objects
        textobjects = {
          select = {
            enable    = true,
            lookahead = true,
            keymaps   = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable          = true,
            set_jumps       = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
          },
        },

        -- Playground for Treesitter queries
        playground = {
          enable          = true,
          updatetime      = 25,
          persist_queries = false,
        },

        -- (Removed p00f/nvim-ts-rainbow settings)
      }

      -- === rainbow-delimiters.nvim setup ===

      -- Define highlight groups with your custom hex colors
      vim.cmd [[
        highlight RainbowDelimiterWhite       guifg=#FFFFFF
        highlight RainbowDelimiterLawnGreen   guifg=#7CFC00
        highlight RainbowDelimiterDeepSkyBlue guifg=#00BFFF
        highlight RainbowDelimiterOrangeRed   guifg=#FF4500
        highlight RainbowDelimiterLime        guifg=#00FF00
        highlight RainbowDelimiterDodgerBlue  guifg=#1E90FF
        highlight RainbowDelimiterRed         guifg=#FF0000
        highlight RainbowDelimiterGreen2      guifg=#00CC00
        highlight RainbowDelimiterRoyalBlue   guifg=#4169E1
        highlight RainbowDelimiterCrimson     guifg=#DC143C
      ]]

      -- Configure rainbow-delimiters.nvim
      require("rainbow-delimiters.setup").setup {
        -- use the global (buffer-wise) strategy for all filetypes
        strategy = {
          [""] = "rainbow-delimiters.strategy.global",
        },
        -- use the default "rainbow-delimiters" query for all filetypes
        query = {
          [""] = "rainbow-delimiters",
        },
        -- assign your custom highlight groups, in nesting order
        highlight = {
          "RainbowDelimiterWhite",
          "RainbowDelimiterLawnGreen",
          "RainbowDelimiterDeepSkyBlue",
          "RainbowDelimiterOrangeRed",
          "RainbowDelimiterLime",
          "RainbowDelimiterDodgerBlue",
          "RainbowDelimiterRed",
          "RainbowDelimiterGreen2",
          "RainbowDelimiterRoyalBlue",
          "RainbowDelimiterCrimson",
        },
      }
    end,
  },
}

