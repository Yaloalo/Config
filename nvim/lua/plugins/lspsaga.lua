-- ~/.config/nvim/lua/plugins/lspsaga.lua
return {
  -- 1) Lspsaga + your keymaps (unchanged)
  {
    "nvimdev/lspsaga.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    event = "LspAttach",
    config = function()
      local ok, saga = pcall(require, "lspsaga")
      if not ok then
        vim.notify("Lspsaga failed to load: " .. tostring(saga), vim.log.levels.ERROR)
        return
      end

      -- keep symbol provider, but disable its own winbar/autocmd
      saga.setup({
        symbol_in_winbar = { enable = false },
        lightbulb = { enable = false },
      })

      vim.o.showmode = false
      vim.o.termguicolors = true

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }
      map("n", "<leader>lD", "<cmd>Lspsaga hover_doc<CR>", opts)
      map("n", "<leader>lA", "<cmd>Lspsaga code_action<CR>", opts)
      map("n", "<leader>lH", "<cmd>Lspsaga incoming_calls<CR>", opts)
      map("n", "<leader>lI", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
      map("n", "<leader>lO", "<cmd>Lspsaga outline<CR>", opts)
      map("n", "<leader>lR", "<cmd>Lspsaga rename<CR>", opts)
    end,
  },

  -- 2) Lualine + Bubbles theme, with #1a1b26 as “black”
  -- 2) Lualine + Bubbles theme on top, simple bottom statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.o.showtabline    = 2
      vim.o.laststatus     = 3
      vim.o.termguicolors  = true
      vim.o.winbar = ""

      -- your custom palette
      local colors = {
        blue   = "#80a0ff",  -- normal
        green  = "#a3be8c",  -- insert
        violet = "#d183e8",  -- visual
        black  = "#1a1b26",
        white  = "#c6c6c6",
        grey   = "#303030",
        red    = "#ff5189",  -- replace
        cyan   = "#79dac8",  -- visual/other
      }

      local bubbles_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.blue },
          b = { fg = colors.white, bg = colors.grey },
          c = { fg = colors.white, bg = colors.black },
        },
        insert = {
          a = { fg = colors.black, bg = colors.green },
        },
        visual = {
          a = { fg = colors.black, bg = colors.violet },
        },
        replace = {
          a = { fg = colors.black, bg = colors.red },
        },
        inactive = {
          a = { fg = colors.white, bg = colors.black },
          b = { fg = colors.white, bg = colors.black },
          c = { fg = colors.white, bg = colors.black },
        },
      }

      require("lualine").setup({
        options = {
          theme                = bubbles_theme,
          component_separators = "",
          section_separators   = "",
          globalstatus         = true,
        },
        tabline = {
          lualine_c = {
            {
              function()
                local ok, winbar_mod = pcall(require, "lspsaga.symbol.winbar")
                if not ok then return "" end
                return winbar_mod.get_bar() or ""
              end,
              cond = function()
                local ok, winbar_mod = pcall(require, "lspsaga.symbol.winbar")
                return ok and (winbar_mod.get_bar() or "") ~= ""
              end,
            },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            {
              "filename",
              path    = 1,
              symbols = { modified = "[+]" },
            }
          },
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = { "filename" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "location" },
        },
        extensions = {},
      })
    end,
  },

}
