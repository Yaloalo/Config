-- ~/.config/nvim/lua/plugins/flash.lua
-- Flash: stronger label contrast + place label before match for readability.
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    labels = "asdfghjklqwertyuiopzxcvbnm",
    -- keep "/" and "?" vanilla
    modes = { search = { enabled = false }, char = { enabled = true, jump_labels = true, multi_line = true } },
    -- make labels stand out and appear *before* the match
    label = {
      uppercase = true,
      current = true,
      before = true,
      after = false,
      style = "inline", -- render the label inline so it doesn’t sit on top of the match
      format = function(opts)
        -- draw a clear “pill” like [D] (customize if you want)
        return { { "[" .. opts.match.label .. "]", "FlashLabel" } }
      end,
    },
    highlight = {
      backdrop = true,
      matches = true,
      groups = {
        match = "FlashMatch",
        current = "FlashCurrent",
        backdrop = "FlashBackdrop",
        label = "FlashLabel", -- we’ll set this below
      },
    },
    remote_op = { restore = true, motion = true },
  },
  config = function(_, opts)
    require("flash").setup(opts)

    local function get_hl(name)
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
      return ok and hl or {}
    end

    local function set_flash_hl()
      -- keep matches linked to your theme
      vim.api.nvim_set_hl(0, "FlashMatch",   { link = "Search" })
      vim.api.nvim_set_hl(0, "FlashCurrent", { link = "IncSearch" })
      vim.api.nvim_set_hl(0, "FlashBackdrop",{ link = "Comment" })

      -- HIGH-CONTRAST label “pill”
      -- bg: bright, fg: dark, bold, nocombine so it never blends with other hl
      local normal = get_hl("Normal")
      local label_fg = normal.bg and 0x000000 or 0x000000
      local label_bg = 0xFFD200 -- amber; change if it clashes with your theme

      vim.api.nvim_set_hl(0, "FlashLabel", {
        fg = label_fg,
        bg = label_bg,
        bold = true,
        underline = true,
        nocombine = true,
      })
    end

    set_flash_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("FlashCustomHL", { clear = true }),
      callback = set_flash_hl,
    })
  end,
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,               desc = "Flash: Jump" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,         desc = "Flash: Treesitter" },
    { "r", mode = "o",                 function() require("flash").remote() end,           desc = "Flash: Remote (op-pending)" },
    { "R", mode = { "o", "x" },        function() require("flash").treesitter_search() end,desc = "Flash: TS Search" },
  },
}

