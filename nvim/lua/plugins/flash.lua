-- plugins/flash.lua
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- global defaults
    highlight = {
      backdrop = false,      -- don’t dim the rest of the screen
      matches = true,        -- highlight all matches (existing text match highlight)
    },
    -- enable modes
    modes = {
      search = {
        enabled      = true,  -- hook into / and ?
        multi_window = true,  -- label matches in all visible windows
      },
      char = {
        jump_labels = true,   -- label f, t, F, T targets
        multi_window = true,  -- label across splits for char mode
      },
    },
  },
  -- after setup, override FlashLabel highlight to stand out (orange)
  config = function(_, opts)
    require("flash").setup(opts)
    -- set FlashLabel group to orange for better visibility
    vim.cmd("highlight FlashLabel guifg=#FFA500 guibg=none gui=bold")
  end,
  keys = {
    -- Enhanced f, t, F, T
    { "f", mode = { "n", "x", "o" }, function() require("flash").jump({ mode = "char", multi_window = true }) end, desc = "Flash f" },
    { "F", mode = { "n", "x", "o" }, function() require("flash").jump({ mode = "char", backward = true, multi_window = true }) end, desc = "Flash F" },
    { "t", mode = { "n", "x", "o" }, function() require("flash").jump({ mode = "char", jump = { pos = "before" }, multi_window = true }) end, desc = "Flash t" },
    { "T", mode = { "n", "x", "o" }, function() require("flash").jump({ mode = "char", backward = true, jump = { pos = "before" }, multi_window = true }) end, desc = "Flash T" },

    -- Generic fuzzy-search jump: <leader>j (prompt starts empty)
    { "<leader>j", mode = "n", function()
        require("flash").jump({
          search = { mode = "fuzzy", multi_window = true },
          label  = { after = {0,0} },
          -- no initial pattern: start with an empty prompt
        })
      end, desc = "Flash fuzzy search (generic)" },

    -- Treesitter, remote, toggle
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o",           function() require("flash").remote() end,      desc = "Flash Remote" },
    { "<c-s>", mode = "c",       function() require("flash").toggle() end,      desc = "Toggle Flash Search" },
  },
}

