-- ~/.config/nvim/lua/plugins.lua
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x", -- v3 is the current stable
    dependencies = {
      "nvim-lua/plenary.nvim", -- required utility functions
      "MunifTanjim/nui.nvim", -- UI component library
      "nvim-tree/nvim-web-devicons", -- icons
    },
    config = function()
      -- Basic setup with some sensible defaults
      require("neo-tree").setup({
        close_if_last_window = true, -- close Neo-tree if it's the last window
        enable_git_status = true, -- show git status icons
        enable_diagnostics = false, -- turn on diagnostics if you like
        filesystem = {
          follow_current_file = true, -- highlight the active file
          hijack_netrw_behavior = "open_default",
        },
        window = {
          position = "left",
          width = 30,
          mappings = {
            -- disable builtin `o` to open files so you can remap if needed
            ["o"] = "open",
          },
        },
        default_component_configs = {
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "ﰊ",
          },
        },
      })

      -- Map \ to toggle Neo-tree
      vim.keymap.set(
        "n", -- normal mode
        "\\", -- key
        function() -- action
          require("neo-tree.command").execute({ toggle = true })
        end,
        { desc = "Toggle Neo-tree", noremap = true, silent = true }
      )
    end,
  },

  -- … more plugins …
}
