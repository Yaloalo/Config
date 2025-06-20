return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    -- we remove the default mapping so we can define our own below
    start_in_insert = true,
    direction       = "float",
    float_opts      = {
      border   = "rounded",
      winblend = 0,
    },
    shade_terminals = false,
    shell           = "zsh",
    shellcmdflag    = "-i",
  },
  config = function(_, opts)
    -- ensure <leader> is defined
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    local toggleterm = require("toggleterm")
    toggleterm.setup(opts)

    -- standard terminal toggle
    vim.keymap.set({ "n", "t" }, "<leader>t", "<Cmd>ToggleTerm<CR>", {
      desc = "Toggle Terminal",
    })

    -- prepare a floating terminal for yazi
    local Terminal = require("toggleterm.terminal").Terminal
    local yazi_term = Terminal:new({
      cmd        = "yazi",
      dir        = vim.loop.cwd(),   -- initial cwd
      hidden     = true,
      direction  = "float",
      float_opts = opts.float_opts,
    })

    -- toggle yazi, *updating* its dir each time to the current cwd
    vim.keymap.set("n", "<leader>sr", function()
      yazi_term.dir = vim.loop.cwd()
      yazi_term:toggle()
    end, { desc = "󰉓 Toggle yazi (file manager)" })
  end,
}
