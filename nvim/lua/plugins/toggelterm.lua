return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    -- remove open_mapping; we’ll define our own mappings below
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
    local toggleterm = require("toggleterm")
    toggleterm.setup(opts)

    -- ⮕ Standard toggleterm mapping
    vim.keymap.set({ "n", "t" }, "<leader>t", "<Cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })

    -- ───────────────────────────────────────────────────────────────────
    -- Create a dedicated floating terminal for yazi
    -- ───────────────────────────────────────────────────────────────────
    local Terminal = require("toggleterm.terminal").Terminal

    -- Use vim.loop.cwd() so it always picks up the current buffer's cwd
    local yazi_term = Terminal:new({
      cmd         = "yazi",
      dir         = vim.loop.cwd(),
      hidden      = true,
      direction   = "float",
      float_opts  = opts.float_opts,
    })

    -- Map <leader>sr to toggle our yazi terminal
    vim.keymap.set("n", "<leader>sr", function()
      -- update dir each time in case you've changed cwd
      yazi_term.cwd = vim.loop.cwd()
      yazi_term:toggle()
    end, { desc = "󰉓 Toggle yazi (file manager)" })
  end,
}
