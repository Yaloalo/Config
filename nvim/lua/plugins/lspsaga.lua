-- ~/.config/nvim/lua/plugins/lspsaga.lua
return {
  {
    -- make sure you have installed this exact repo
    "nvimdev/lspsaga.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- 1) Initialize Saga with default settings (override here if you like)
      require("lspsaga").setup({})

      -- 2) Create your <leader>l* mappings
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Hover documentation
      map(
        "n",
        "<leader>lD",
        "<cmd>Lspsaga hover_doc<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Hover Doc" })
      )

      -- Code actions
      map(
        "n",
        "<leader>lA",
        "<cmd>Lspsaga code_action<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Code Action" })
      )

      -- Call Hierarchy (incoming calls)
      map(
        "n",
        "<leader>lH",
        "<cmd>Lspsaga incoming_calls<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Incoming Calls" })
      )

      -- Diagnostics for current line in a float
      map(
        "n",
        "<leader>lI",
        "<cmd>Lspsaga show_line_diagnostics<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Line Diagnostics" })
      )

      -- Outline of symbols
      map(
        "n",
        "<leader>lO",
        "<cmd>Lspsaga outline<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Outline" })
      )

      -- Rename symbol
      map(
        "n",
        "<leader>lR",
        "<cmd>Lspsaga rename<CR>",
        vim.tbl_extend("force", opts, { desc = "Lspsaga: Rename" })
      )

      -- Floating terminal
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
