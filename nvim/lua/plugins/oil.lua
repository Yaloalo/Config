-- lua/plugins/oil.lua
return {
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional icon support
    },
    -- load immediately so file-explorer is always ready
    lazy = false,
    config = function()
      -- Basic Oil setup
      require("oil").setup({
        -- Take over directory buffers (e.g. `nvim .` or `:e src/`)
        default_file_explorer = true,
        skip_confirm_for_simple_edits = true,
        -- Show hidden files by default
        view_options = {
          show_hidden = true,
          is_hidden_file = function(name, bufnr)
            return vim.startswith(name, ".")
          end,
        },
        -- Use default keymaps, plus parent-folder shortcut
        use_default_keymaps = true,
        keymaps = {
          -- Open file or directory
          ["<CR>"] = "actions.select",
          -- Go to parent directory
          ["-"] = "actions.parent",
          -- Change directory to cwd
          ["_"] = "actions.open_cwd",
          -- Show help
          ["g?"] = "actions.show_help",
        },
        -- Buffer-local options for oil buffers
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        -- Window-local options for oil buffers
        win_options = {
          wrap = false,
          signcolumn = "no",
          cursorcolumn = false,
          foldcolumn = "0",
        },
      })

      -- Open Oil at initial Neovim cwd
      vim.keymap.set("n", "<leader>oo", function()
        require("oil").open(vim.fn.getcwd())
      end, { desc = "󱎘 Oil Explorer (initial cwd)" })

      -- Open Oil at parent directory of current file
      vim.keymap.set("n", "<leader>oc", function()
        local dir = vim.fn.expand("%:p:h")
        require("oil").open(dir)
      end, { desc = "󱎘 Oil Explorer (current file parent)" })
    end,
  },
}
