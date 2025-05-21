-- ~/.config/nvim/lua/plugins/lspsaga.lua
return {
  {
    "nvimdev/lspsaga.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- 1. Setup lspsaga without auto winbar (we'll render breadcrumb in the statusline)
      require("lspsaga").setup({
        symbol_in_winbar = {
          enable = false, -- disable built-in winbar
          separator = "  ", -- breadcrumb separator
          show_file = true, -- show filename in breadcrumb
          folder_level = 2, -- folder depth for file context
        },
      })

      -- 2. Always show statusline, hide mode indicator
      vim.o.laststatus = 2
      vim.o.showmode = false

      -- 3. Define breadcrumb function for statusline
      _G.SagaBreadcrumb = function()
        -- Empty when no buffer/file is open
        if vim.fn.empty(vim.fn.bufname("%")) == 1 then
          return ""
        end
        -- Try to get LSP-Saga breadcrumb
        local bar = require("lspsaga.symbol.winbar").get_bar()
        if bar and bar ~= "" then
          return bar
        end
        -- Fallback to filename only
        return vim.fn.expand("%:t")
      end

      -- 4. Hook breadcrumb into statusline
      vim.o.statusline = "%!v:lua.SagaBreadcrumb()"

      -- 5. Key mappings for Lspsaga actions
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map(
        "n",
        "<leader>lD",
        "<cmd>Lspsaga hover_doc<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Hover Doc" })
      )
      map(
        "n",
        "<leader>lA",
        "<cmd>Lspsaga code_action<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Code Action" })
      )
      map(
        "n",
        "<leader>lH",
        "<cmd>Lspsaga incoming_calls<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Incoming Calls" })
      )
      map(
        "n",
        "<leader>lI",
        "<cmd>Lspsaga show_line_diagnostics<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Line Diagnostics" })
      )
      map(
        "n",
        "<leader>lO",
        "<cmd>Lspsaga outline<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Outline" })
      )
      map(
        "n",
        "<leader>lR",
        "<cmd>Lspsaga rename<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Rename" })
      )
      map(
        "n",
        "<leader>t",
        "<cmd>Lspsaga term_toggle<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Toggle Terminal" })
      )
      map(
        "t",
        "<leader>lF",
        "<cmd>Lspsaga term_toggle<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Toggle Terminal" })
      )
    end,
  },
}
