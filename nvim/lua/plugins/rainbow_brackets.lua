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
      { pattern = { "*", "LazyColorScheme" }, callback = set_groups }
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

    ---------------------------------------------------------------------------
    -- 3) SUPER HACK: always (re)enable TS highlight + rainbow, no checks
    ---------------------------------------------------------------------------
    local function slam(buf)
      buf = buf or vim.api.nvim_get_current_buf()
      -- Re-start TS highlight unconditionally
      -- NVIM ≥0.10
      pcall(vim.treesitter.start, buf)
      -- Fallback for older NVIM (safe even on 0.10):
      pcall(vim.cmd, "silent! TSBufEnable highlight")
      -- Re-enable rainbow
      pcall(function() require("rainbow-delimiters").enable(buf) end)
    end

    local grp = vim.api.nvim_create_augroup("ForceRainbowAlways", { clear = true })
    vim.api.nvim_create_autocmd(
      { "BufEnter", "BufWinEnter", "CursorMoved", "CursorMovedI", "WinScrolled",
        "TextChanged", "TextChangedI", "LspAttach", "User" },
      {
        group = grp,
        pattern = { "*", "TSBufEnter", "TSBufDetach", "LazyColorScheme" },
        callback = function(a) slam(a.buf) end,
      }
    )

    -- Optional watchdog every 300ms (comment out if you hate timers)
    local timer = vim.loop.new_timer()
    timer:start(300, 300, vim.schedule_wrap(function()
      if vim.api.nvim_get_mode().mode ~= "c" then
        slam()
      end
    end))
  end,
}

