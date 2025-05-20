-- ~/.config/nvim/lua/plugins/snacks.lua
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  -- snacks.nvim configuration
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = true },
    notifier = { enabled = false, timeout = 3000 },
    picker = { enabled = false },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = false },
    terminal = { enabled = true },

    -- ▶️ 1. Toggle module (uses default settings; customize inside if you like)
    toggle = {
      -- e.g. icon = { enabled = " ", disabled = " " },
      --      color = { enabled = "green", disabled = "yellow" },
      --      map   = vim.keymap.set,
      --      which_key = true,
      --      notify    = true,
    },

    -- 🖼️ 2. Image module (default settings; customize below as needed)
    image = {
      -- enabled = true,
      -- formats = { "png","jpg","gif","bmp","webp","pdf", ... },
      -- doc = { enabled = true, inline = true, float = true, max_width = 80, max_height = 40 },
      -- wo = { wrap = false, number = false, relativenumber = false, ... },
      -- convert = { ... },
      -- cache   = vim.fn.stdpath("cache") .. "/snacks/image",
      -- debug   = { request = false, convert = false, placement = false },
    },

    styles = {
      notification = {
        -- wo = { wrap = true },
      },
    },
  },

  keys = {},

  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Debug helpers
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd
      end,
    })
  end,
}
