-- lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/playground",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    local languages = { "bash","c","cpp","lua","python","javascript","typescript","html","css","markdown","vim","query","rust","zig", "asm", "svelte", "haskell" }
    if vim.fn.executable("tree-sitter") == 1 then
      table.insert(languages, "latex")
    else
      vim.notify("tree-sitter CLI not found; skipping latex parser install", vim.log.levels.WARN)
    end
    require("nvim-treesitter.configs").setup {
      ensure_installed = languages,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent    = { enable = true, disable = { "python" } },
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
          enable = true, lookahead = true,
          keymaps = {
            ["af"] = "@function.outer", ["if"] = "@function.inner",
            ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true, set_jumps = true,
          goto_next_start    = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
          goto_previous_start= { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
        },
      },
      playground = { enable = true, updatetime = 25, persist_queries = false },
    }
  end,
}
