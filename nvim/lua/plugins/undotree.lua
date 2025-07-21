-- lua/plugins/undotree.lua
return {
  {
    "mbbill/undotree",
    -- lazy-load only when you actually request it
    cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide", "UndotreeFocus" },
    event = "BufReadPost",
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<CR>", desc = "Toggle UndoTree" },
      { "<leader>us", "<cmd>UndotreeShow<CR>", desc = "Show UndoTree" },
      { "<leader>uh", "<cmd>UndotreeHide<CR>", desc = "Hide UndoTree" },
      { "<leader>uf", "<cmd>UndotreeFocus<CR>", desc = "Focus UndoTree" },
    },
    config = function()

      -- Undotree UI settings
      vim.g.undotree_WindowLayout = 2 -- side-by-side
      vim.g.undotree_DiffpanelHeight = 10
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_SetFocusWhenToggle = 1

      -- buffer-local <leader>u mappings in the undotree window
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "undotree",
        callback = function()
          local opts = { buffer = true, noremap = true, silent = true }
          -- open selected node       (o / <CR>)
          vim.keymap.set("n", "<leader>uo", "o", opts)
          -- diff against current     (D)
          vim.keymap.set("n", "<leader>ud", "D", opts)
          -- toggle timestamps        (t)
          vim.keymap.set("n", "<leader>ut", "t", opts)
          -- quick-help               (?)
          vim.keymap.set("n", "<leader>u?", "?", opts)
        end,
      })
    end,
  },
}
