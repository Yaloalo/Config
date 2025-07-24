-- lua/plugins/rainbow.lua
return {
  "HiPhish/rainbow-delimiters.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  lazy = false,
  priority = 1000,

  config = function()
    ---------------------------------------------------------------------------
    -- 1) Highlight groups
    ---------------------------------------------------------------------------
    local function set_groups()
      local set = vim.api.nvim_set_hl
      set(0, "RainbowDelimiterWhite"      , { fg = "#FFFFFF" })
      set(0, "RainbowDelimiterLawnGreen"  , { fg = "#7CFC00" })
      set(0, "RainbowDelimiterDeepSkyBlue", { fg = "#00BFFF" })
      set(0, "RainbowDelimiterOrangeRed"  , { fg = "#FF4500" })
      set(0, "RainbowDelimiterLime"       , { fg = "#00FF00" })
      set(0, "RainbowDelimiterDodgerBlue" , { fg = "#1E90FF" })
      set(0, "RainbowDelimiterRed"        , { fg = "#FF0000" })
      set(0, "RainbowDelimiterGreen2"     , { fg = "#00CC00" })
      set(0, "RainbowDelimiterRoyalBlue"  , { fg = "#4169E1" })
      set(0, "RainbowDelimiterCrimson"    , { fg = "#DC143C" })
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
    require("rainbow-delimiters.setup").setup {
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

