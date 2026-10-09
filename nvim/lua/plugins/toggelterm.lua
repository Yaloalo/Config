-- ~/.config/nvim/lua/plugins/yazi.lua
return {
  "mikavilpas/yazi.nvim",
  event        = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>oy", mode = { "n","v" }, "<cmd>Yazi<cr>", desc = "Open Yazi file manager" },
  },
  opts = {
    open_for_directories = false,
    keymaps = { show_help = "?" },
    open_file_function = function(chosen_file)
      -- this runs inside Neovim, so we can just edit the file here:
      vim.cmd("edit " .. vim.fn.fnameescape(chosen_file))
    end,
  },
}
