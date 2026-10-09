-- File: lua/plugins/compiler_tools.lua
-- Load with lazy.nvim by adding `require('plugins.compiler_tools')` in your lazy setup

return {
  -- Hex editing in Neovim using hexmode.nvim
  {
    "RaafatTurki/hex.nvim",
    config = function()
      require("hex").setup({
        -- Use xxd by default; ensure xxd is in $PATH
        dump_cmd = "xxd -g 1 -u",
        assemble_cmd = "xxd -r",
      })
      local map = vim.keymap.set
      -- <leader>ch to toggle hex view
      map("n", "<leader>ch", "<cmd>HexToggle<CR>", { desc = "Toggle Hex View" })
    end,
  },
  -- Compiler Explorer integration (krady21/compiler-explorer.nvim)
  {
    "krady21/compiler-explorer.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("compiler-explorer").setup({})
      local map = vim.keymap.set
      -- <leader>c prefix for Compiler Explorer commands
      map("n", "<leader>cc", "<cmd>CECompile<CR>", { desc = "CE: Compile" })
      map("n", "<leader>cl", "<cmd>CECompileLive<CR>", { desc = "CE: Compile Live" })
      map("n", "<leader>cf", "<cmd>CEFormat<CR>", { desc = "CE: Format Code" })
      map("n", "<leader>cL", "<cmd>CEAddLibrary<CR>", { desc = "CE: Add Library" })
      map("n", "<leader>cx", "<cmd>CELoadExample<CR>", { desc = "CE: Load Example" })
      map("n", "<leader>co", "<cmd>CEOpenWebsite<CR>", { desc = "CE: Open Website" })
      map("n", "<leader>cd", "<cmd>CEDeleteCache<CR>", { desc = "CE: Clear Cache" })
      map("n", "<leader>ct", "<cmd>CEShowTooltip<CR>", { desc = "CE: Show Tooltip" })
      map("n", "<leader>cg", "<cmd>CEGotoLabel<CR>", { desc = "CE: Goto Label" })
    end,
  },
}
