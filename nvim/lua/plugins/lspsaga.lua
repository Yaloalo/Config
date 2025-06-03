-- ~/.config/nvim/lua/plugins/lspsaga.lua
return {
  {
    "nvimdev/lspsaga.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- 1. Enable Lspsaga’s built-in winbar (at top of window)
      require("lspsaga").setup({
        symbol_in_winbar = {
          enable = true, -- turn on winbar
          separator = "  ",
          show_file = true,
          folder_level = 2,
        },
        lightbulb = {
          enable = false, -- disable the lightbulb indicator
        },
      })

      -- 2. Hide the bottom statusline and builtin “-- INSERT --” text
      vim.o.laststatus = 0
      vim.o.showmode = false

      -- 3. Key mappings for Lspsaga actions (preserved from your original)
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
    end,
  },
}
