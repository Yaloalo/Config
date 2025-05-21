-- lua/plugins/treesitter.lua
return {
  -- core nvim-treesitter plugin
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- always use latest
    build = ":TSUpdate",
    dependencies = {
      -- rainbow-delimiters.nvim (uses its own setup API, not the old ts-module system)
      {
        "HiPhish/rainbow-delimiters.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
          require("rainbow-delimiters.setup").setup({
            strategy = {
              [""] = "rainbow-delimiters.strategy.global",
            },
          })
        end,
      },

      "nvim-treesitter/playground", -- interactive query inspector
      "nvim-treesitter/nvim-treesitter-textobjects", -- textobjects (select/move)
    },
    opts = {
      -- 1) Parsers to install
      ensure_installed = {
        "bash",
        "c",
        "lua",
        "python",
        "javascript",
        "typescript",
        "html",
        "css",
        "markdown",
        "vim",
        "query",
        "latex",
      },
      sync_install = false,
      auto_install = true,

      -- 2) Highlight & indent
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
      },
      indent = {
        enable = true,
        disable = { "python" },
      },

      -- 3) Incremental selection (gnn/grn/grc/grm)
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },

      -- 4) Textobjects: select/move between functions & classes
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- update jumplist
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

      -- 5) Playground: inspect treesitter queries in real time
      playground = {
        enable = true,
        updatetime = 25,
        persist_queries = false,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- treesitter-context (show current function/class at top of window)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 5,
        trim_scope = "outer",
        patterns = {
          default = {
            "class",
            "function",
            "method",
            "for",
            "while",
            "if",
            "switch",
            "case",
          },
        },
      })
    end,
  },
}
