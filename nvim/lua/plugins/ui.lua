-- ~/.config/nvim/lua/plugins/ui.lua

-- Enable true-color support
vim.o.termguicolors = true

-- ──────────────────────────────────────────────────────────────────────────────
-- Winbar + Mode Indicator (top of window), entire line colored per mode
-- ──────────────────────────────────────────────────────────────────────────────

-- 1) Predefine our colors for each mode
local mode_colors = {
  n = "#569CD6", -- Normal = blue
  i = "#6A9955", -- Insert = green
  v = "#C586C0", -- Visual = purple
}

-- 2) Function to update the WinBar highlight and text
local function update_winbar()
  -- a) Determine current mode (first character: 'n', 'i', 'v', etc.)
  local m = vim.api.nvim_get_mode().mode:sub(1, 1)
  -- b) Pick a color (default to Normal if unknown)
  local color = mode_colors[m] or mode_colors.n
  -- c) Re-set the global WinBar highlight group to that color
  vim.api.nvim_set_hl(0, "WinBar", { fg = color })
  -- d) Grab Lspsaga’s breadcrumb (may be empty)
  local bar = require("lspsaga.symbol.winbar").get_bar() or ""
  -- e) Compose the winbar: "[MODE]  breadcrumb…"
  --    We rely on the WinBar group we just set, so no inline %#…# codes here.
  vim.opt.winbar = string.format(" %s %s", m:upper(), bar)
end

-- 3) Auto-run on buffer/window enter and mode changes
local grp = vim.api.nvim_create_augroup("SagaWinbarMode", { clear = true })
vim.api.nvim_create_autocmd(
  { "BufEnter", "WinEnter", "ModeChanged" },
  { group = grp, callback = update_winbar }
)

-- ──────────────────────────────────────────────────────────────────────────────
-- Your existing plugin specs: theme, dashboard, TODO-comments
-- ──────────────────────────────────────────────────────────────────────────────

return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      terminal_colors = true,
    },
    config = function(_, opts)
      local is_transparent = opts.transparent
      local function apply()
        require("tokyonight").setup(vim.tbl_extend("force", opts, { transparent = is_transparent }))
        vim.cmd("colorscheme tokyonight")
      end
      local function toggle()
        is_transparent = not is_transparent
        apply()
      end
      apply()
      vim.keymap.set("n", "<leader>b", toggle, { desc = "Toggle Tokyo Night transparency" })
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
