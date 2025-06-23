-- Enable true-color support
vim.o.termguicolors = true

-- ──────────────────────────────────────────────────────────────────────────────
-- Winbar + Mode Indicator (top of window), entire line colored per mode
-- ──────────────────────────────────────────────────────────────────────────────
--[[
local mode_colors = {
  n = "#569CD6", -- Normal = blue
  i = "#6A9955", -- Insert = green
  v = "#C586C0", -- Visual = purple
}

local function update_winbar()
  local m = vim.api.nvim_get_mode().mode:sub(1, 1)
  local color = mode_colors[m] or mode_colors.n
  vim.api.nvim_set_hl(0, "WinBar", { fg = color })
  local bar = require("lspsaga.symbol.winbar").get_bar() or ""
  if bar == "" then
    local bufname = vim.api.nvim_buf_get_name(0)
    local fname = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or "[No Name]"
    bar = fname
  end

  vim.opt.winbar = string.format(" %s %s", m:upper(), bar)
end

local grp = vim.api.nvim_create_augroup("SagaWinbarMode", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "ModeChanged" }, {
  group = grp,
  callback = update_winbar,
})
]]
-- ──────────────────────────────────────────────────────────────────────────────
-- Plugins and UI Appearance
-- ──────────────────────────────────────────────────────────────────────────────

return {
{
  "p00f/alabaster.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    -- ensure truecolor
    vim.o.termguicolors = true
    vim.g.alabaster_dim_comments = false
    vim.g.alabaster_floatborder  = false

    -- your chosen grey
    local grey = "#101010"
    local transparent = false

    local function apply_theme()
      -- load Alabaster colorscheme
      vim.cmd("colorscheme alabaster")

      if transparent then
        -- full transparency
        vim.cmd([[
          highlight Normal      guibg=NONE
          highlight NormalFloat guibg=NONE
          highlight FloatBorder guibg=NONE
        ]])
      else
        -- dark grey background
        vim.cmd(string.format("highlight Normal      guibg=%s", grey))
        vim.cmd(string.format("highlight NormalFloat guibg=%s", grey))
        vim.cmd(string.format("highlight FloatBorder guibg=%s", grey))
      end
    end

    -- initial application
    apply_theme()

    -- toggle with <leader>b
    vim.keymap.set("n", "<leader>b", function()
      transparent = not transparent
      apply_theme()
    end, { desc = "Toggle Alabaster Background Transparency" })
  end,
},

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        views = {
          cmdline_popup = {
            position = { row = 5, col = "50%" },
            size = { width = 60, height = "auto" },
            border = { style = "rounded", padding = { 0, 1 } },
            win_options = {
              winhighlight = {
                FloatBorder = "NoiceWhiteBorder",
                Normal = "NormalFloat",
              },
            },
          },
          popupmenu = {
            relative = "editor",
            position = { row = 8, col = "50%" },
            size = { width = 60, height = 10 },
            border = { style = "rounded", padding = { 0, 1 } },
            win_options = {
              winhighlight = {
                FloatBorder = "NoiceWhiteBorder",
                Normal = "NormalFloat",
              },
            },
          },
        },
      })


      vim.api.nvim_set_hl(0, "NoiceWhiteBorder", { fg = "#ffffff", bg = "none" })
    end,
  },

  {
    "goolord/alpha-nvim",
    dependencies = { "echasnovski/mini.icons", "nvim-lua/plenary.nvim" },
    config = function()
      require("alpha").setup(require("alpha.themes.theta").config)
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
}
