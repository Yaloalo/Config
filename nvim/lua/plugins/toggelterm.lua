return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    -- remove this:
    -- open_mapping = [[<leader>t]],

    start_in_insert = true,
    direction = "float",
    float_opts = {
      border = "rounded",
      winblend = 0,
    },
    shade_terminals = false,
    shell = "zsh",
    shellcmdflag = "-i",
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    -- add a manual mapping in normal + terminal mode only
    vim.keymap.set({ "n", "t" }, "<leader>t", "<Cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })
  end,
}
