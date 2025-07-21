return {
  -- Treesitter and Rainbow Delimiters configuration for Neovim
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/playground",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "HiPhish/rainbow-delimiters.nvim",
    },
    config = function()
      -- 1) Define vibrant highlight groups for rainbow delimiters
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

      -- 2) Treesitter core setup
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "bash", "c", "cpp", "lua", "python",
          "javascript", "typescript", "html", "css",
          "markdown", "vim", "query", "latex", "rust", "zig"
        },
        sync_install = false,
        auto_install = true,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
          disable = { "python" },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection    = "gnn",
            node_incremental  = "grn",
            scope_incremental = "grc",
            node_decremental  = "grm",
          },
        },
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
        playground = {
          enable          = true,
          updatetime      = 25,
          persist_queries = false,
        },
      }

      -- 3) Rainbow Delimiters setup with global depth-based coloring
      require("rainbow-delimiters.setup").setup {
        strategy = {
          [""] = "rainbow-delimiters.strategy.global",
        },
        query = {
          [""] = "rainbow-delimiters",
        },
        highlight = {
          "RainbowDelimiterWhite",       "RainbowDelimiterLawnGreen",
          "RainbowDelimiterDeepSkyBlue", "RainbowDelimiterOrangeRed",
          "RainbowDelimiterLime",        "RainbowDelimiterDodgerBlue",
          "RainbowDelimiterRed",         "RainbowDelimiterGreen2",
          "RainbowDelimiterRoyalBlue",   "RainbowDelimiterCrimson",
        },
      }
    end,
  },
}

