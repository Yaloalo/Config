-- lua/plugins/rainbow.lua
return {
  "HiPhish/rainbow-delimiters.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  lazy = false,
  priority = 1000,

  config = function()
    local ok_rd, rainbow = pcall(require, "rainbow-delimiters.setup")
    if not ok_rd then
      vim.notify("[rainbow] rainbow-delimiters not found; skipping setup", vim.log.levels.WARN)
      return
    end

    ---------------------------------------------------------------------------
    -- 1) Highlight groups
    ---------------------------------------------------------------------------
    local function set_groups()
      local set = vim.api.nvim_set_hl
      set(0, "RainbowDelimiterWhite"      , { fg = "#FFFFFF" })
      set(0, "RainbowDelimiterLawnGreen"  , { fg = "#DFF8FF" })
      set(0, "RainbowDelimiterDeepSkyBlue", { fg = "#BCEBFF" })
      set(0, "RainbowDelimiterOrangeRed"  , { fg = "#8DD1FF" })
      set(0, "RainbowDelimiterLime"       , { fg = "#58BAFF" })
      set(0, "RainbowDelimiterDodgerBlue" , { fg = "#527FFF" })
      set(0, "RainbowDelimiterRed"        , { fg = "#376DFF" })
      set(0, "RainbowDelimiterGreen2"     , { fg = "#B5C8E6" })
      set(0, "RainbowDelimiterRoyalBlue"  , { fg = "#8190A5" })
      set(0, "RainbowDelimiterCrimson"    , { fg = "#F7FBFF" })
    end

    vim.api.nvim_create_autocmd(
      { "ColorScheme", "User", "LspAttach" },
      {
        pattern = { "*", "LazyColorScheme" },
        callback = set_groups,
        desc = "Re-apply rainbow delimiter highlight groups",
      }
    )
    set_groups()

    ---------------------------------------------------------------------------
    -- 2) rainbow-delimiters setup
    ---------------------------------------------------------------------------
    rainbow.setup {
      strategy  = { [""] = "rainbow-delimiters.strategy.global" },
      query     = { [""] = "rainbow-delimiters" },
      priority  = { [""] = 3000 },
      highlight = {
        "RainbowDelimiterWhite", "RainbowDelimiterLawnGreen",
        "RainbowDelimiterDeepSkyBlue", "RainbowDelimiterOrangeRed",
        "RainbowDelimiterLime", "RainbowDelimiterDodgerBlue",
        "RainbowDelimiterRed", "RainbowDelimiterGreen2",
        "RainbowDelimiterRoyalBlue", "RainbowDelimiterCrimson",
      },
    }
  end,
}
