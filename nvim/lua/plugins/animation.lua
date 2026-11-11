-- lua/plugins/animation.lua
-- Eye candy: cursor smear and smooth scrolling.
return {
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>uc", function() require("smear_cursor").toggle() end, desc = "Toggle cursor smear" },
    },
  },

  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      -- <C-b>/<C-f> stay with transparency and the gitignore toggle.
      mappings = { "<C-u>", "<C-d>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
      hide_cursor = true,
      stop_eof = true,
      easing = "quadratic",
    },
  },

}
