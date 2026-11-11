-- lua/plugins/arrow.lua
-- File bookmarks (Harpoon replacement): <leader>h opens the menu, then a
-- single key jumps. <leader>H bookmarks lines inside the current file.
return {
  {
    "otavioschwanck/arrow.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      show_icons = true,
      -- ';' would shadow Flash's f/t repeat, so stay on the old Harpoon prefix.
      leader_key = "<leader>h",
      buffer_leader_key = "<leader>H",
      save_key = "git_root",
      window = { border = "rounded" },
    },
  },
}
