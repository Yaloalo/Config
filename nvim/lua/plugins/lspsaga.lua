-- ~/.config/nvim/lua/plugins/lspsaga.lua
return {
  {
    "nvimdev/lspsaga.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    event = "LspAttach",
    config = function()
      local ok, saga = pcall(require, "lspsaga")
      if not ok then
        vim.notify("lspsaga failed to load: " .. tostring(saga), vim.log.levels.ERROR)
        return
      end

      -- 1. Setup Saga WITHOUT its winbar autocmds, but leave symbol provider available
      saga.setup({
        symbol_in_winbar = {
          enable = false, -- we’ll hook into its provider ourselves
        },
        lightbulb = { enable = false },
      })

      -- 2. Hide default statusline and mode text
      vim.o.laststatus = 0
      vim.o.showmode = false
      vim.o.termguicolors = true

      -- 3. Highlight group for the big “U”
      vim.api.nvim_set_hl(0, "WinBarModified", { fg = "#FF0000", bold = true })

      -- 4. Our unified updater: draws U + mode color + Lspsaga symbol/file
      local mode_colors = { n = "#569CD6", i = "#6A9955", v = "#C586C0" }

      local function update_winbar()
        local api = vim.api

        -- a) Big “U” if modified (column 1)
        local modified_flag = api.nvim_buf_get_option(0, "modified") and "%#WinBarModified#U%*"
          or ""

        -- b) Mode letter & color
        local m = api.nvim_get_mode().mode:sub(1, 1):upper()
        local color = mode_colors[m:lower()] or mode_colors.n
        api.nvim_set_hl(0, "WinBar", { fg = color })

        -- c) Lspsaga symbol path (falls back to filename)
        local bar = require("lspsaga.symbol.winbar").get_bar() or ""
        if bar == "" then
          local name = api.nvim_buf_get_name(0)
          bar = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"
        end

        -- d) Assemble: U, space, mode, space, symbol/file
        vim.opt.winbar = string.format("%s %s %s", modified_flag, m, bar)
      end

      -- 5. Autocmds: fire on everything that could change location or modified state
      local evts = {
        "BufEnter",
        "WinEnter",
        "CursorMoved",
        "CursorMovedI",
        "ModeChanged",
        "TextChanged",
        "TextChangedI",
        "InsertLeave",
        "BufWritePost",
      }
      local grp = vim.api.nvim_create_augroup("CustomSagaWinbar", { clear = true })
      vim.api.nvim_create_autocmd(evts, {
        group = grp,
        callback = update_winbar,
      })

      -- 6. Lspsaga keymaps
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
}
