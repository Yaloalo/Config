-- lua/plugins/neotree.lua
-- Toggleable file tree for working through the repo. Oil stays the handler
-- for opening directories, so Neo-tree does not hijack netrw.
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Neotree",
    keys = {
      {
        "<leader>e",
        function()
          local sidebar = require("core.oil_sidebar")
          if sidebar.is_open() then
            sidebar.close()
          else
            vim.cmd("Neotree toggle reveal left")
          end
        end,
        desc = "File tree (toggle)",
      },
      { "<leader>E", "<cmd>Neotree focus reveal left<CR>", desc = "File tree (focus)" },
      { "<leader>ge", "<cmd>Neotree float git_status<CR>", desc = "Changed files (git)" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      commands = {
        -- Switch the sidebar to Oil (edit mode) at the directory under the cursor.
        oil_edit = function(state)
          local node = state.tree:get_node()
          local path = node and node.path or state.path
          local dir = (node and node.type == "directory") and path or vim.fs.dirname(path)
          require("core.oil_sidebar").open(dir)
        end,
      },
      window = {
        width = 34,
        mappings = {
          -- Space is the leader key; keep it free inside the tree.
          ["<space>"] = "none",
          ["<Tab>"] = "oil_edit",
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
      filesystem = {
        hijack_netrw_behavior = "disabled",
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          never_show = { ".git" },
        },
      },
    },
  },
}
