-- lua/plugins/toggleterm.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    -- toggle with <leader>t
    open_mapping = [[<leader>t]],
    start_in_insert = true,
    -- use floating window
    direction = "float",
    float_opts = {
      border = "rounded",
      winblend = 0,
    },
    -- don’t shade terminals (so your Tokyo Night bg shows)
    shade_terminals = false,
    -- interactive Zsh (loads your aliases & Starship)
    shell = "zsh",
    shellcmdflag = "-i",
  },
}
