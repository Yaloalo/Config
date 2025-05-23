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
  local m = vim.api.nvim_get_mode().mode:sub(1, 1)
  local color = mode_colors[m] or mode_colors.n
  vim.api.nvim_set_hl(0, "WinBar", { fg = color })
  local bar = require("lspsaga.symbol.winbar").get_bar() or ""
  vim.opt.winbar = string.format(" %s %s", m:upper(), bar)
end

-- 3) Auto-run on buffer/window enter and mode changes
local grp = vim.api.nvim_create_augroup("SagaWinbarMode", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "ModeChanged" }, {
  group = grp,
  callback = update_winbar,
})

-- ──────────────────────────────────────────────────────────────────────────────
-- Plugins and UI Appearance
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

      local function set_float_highlights()
        if is_transparent then
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
          vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopeTitle", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = "none" })
        else
          vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
          vim.api.nvim_set_hl(0, "FloatBorder", { link = "FloatBorder" })
          vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "Normal" })
          vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
          vim.api.nvim_set_hl(0, "TelescopePromptNormal", { link = "Normal" })
          vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
          vim.api.nvim_set_hl(0, "TelescopeTitle", { link = "Title" })
          vim.api.nvim_set_hl(0, "TelescopePromptTitle", { link = "Title" })
          vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { link = "Title" })
          vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { link = "Title" })
        end
      end

      local function apply()
        require("tokyonight").setup(vim.tbl_extend("force", opts, {
          transparent = is_transparent,
          style = "night", -- always use "night"
        }))
        vim.cmd("colorscheme tokyonight")
        set_float_highlights()
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
            position = {
              row = 5,
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = {
                FloatBorder = "NoiceWhiteBorder", -- use our custom group
                Normal = "NormalFloat",
              },
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = 8,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = {
                FloatBorder = "NoiceWhiteBorder",
                Normal = "NormalFloat",
              },
            },
          },
        },
      })

      -- 🔑 Keymap for message history
      vim.keymap.set("n", "<leader>m", function()
        require("noice").cmd("history")
      end, { desc = "Noice: Message History" })

      -- 🎨 Define white border color
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
