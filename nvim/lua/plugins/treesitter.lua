-- lua/plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    dependencies = {
      {
        "HiPhish/rainbow-delimiters.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
          local api = vim.api

          -- 1) Alternate White → G1 → B1 → R1 → G2 → B2 → R2 → G3 → B3 → R3
          local greens = { "#7CFC00", "#00FF00", "#00CC00" } -- vibrant greens
          local blues = { "#00BFFF", "#1E90FF", "#4169E1" } -- vibrant blues
          local reds = { "#FF4500", "#FF0000", "#DC143C" } -- vibrant reds

          local palette = { "#FFFFFF" } -- level 1: white
          for i = 1, 3 do
            table.insert(palette, greens[i])
            table.insert(palette, blues[i])
            table.insert(palette, reds[i])
          end
          -- now palette = { White, G1, B1, R1, G2, B2, R2, G3, B3, R3 }

          -- 2) Register highlight groups
          local groups = {}
          for i, col in ipairs(palette) do
            local name = "RainbowLevel" .. i
            api.nvim_set_hl(0, name, { fg = col })
            groups[#groups + 1] = name
          end

          -- 3) Hook into rainbow-delimiters.nvim
          require("rainbow-delimiters.setup").setup({
            strategy = { [""] = "rainbow-delimiters.strategy.global" },
            query = { [""] = "rainbow-delimiters" },
            highlight = groups,
            max_file_lines = 2000,
          })
        end,
      },

      "nvim-treesitter/playground",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
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

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
      },
      indent = {
        enable = true,
        disable = { "python" },
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
          goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
        },
      },

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
}
