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

      -- 1. Setup Saga with winbar symbols
      saga.setup({
        symbol_in_winbar = {
          enable = true,
          separator = "  ",
          show_file = true,
          folder_level = 2,
        },
        lightbulb = { enable = false },
      })

      -- 2. Hide default statusline and mode text
      vim.o.laststatus = 0
      vim.o.showmode = false

      -- 3. Mode-colored Winbar + Mode indicator
      vim.o.termguicolors = true
      local mode_colors = { n = "#569CD6", i = "#6A9955", v = "#C586C0" }
      local function update_winbar()
        -- mode letter
        local m = vim.api.nvim_get_mode().mode:sub(1, 1)
        local color = mode_colors[m] or mode_colors.n
        vim.api.nvim_set_hl(0, "WinBar", { fg = color })
        -- get saga's symbol path
        local bar = require("lspsaga.symbol.winbar").get_bar() or ""
        if bar == "" then
          local buf = vim.api.nvim_buf_get_name(0)
          bar = buf ~= "" and vim.fn.fnamemodify(buf, ":t") or "[No Name]"
        end
        vim.opt.winbar = string.format(" %s %s", m:upper(), bar)
      end
      local grp = vim.api.nvim_create_augroup("SagaWinbarMode", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "ModeChanged" }, {
        group = grp,
        callback = update_winbar,
      })

      -- 4. Key mappings for Saga actions
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
