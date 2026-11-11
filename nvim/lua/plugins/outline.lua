-- lua/plugins/outline.lua
-- Heading outline for Markdown: sidebar, floating nav, and { / } to jump
-- headings. The Telescope picker lives in telescope.lua (<leader>so).
return {
  {
    "stevearc/aerial.nvim",
    ft = { "markdown" },
    cmd = { "AerialToggle", "AerialNavToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>a", "<cmd>AerialToggle! right<CR>", desc = "Outline (toggle)" },
      { "<leader>A", "<cmd>AerialNavToggle<CR>", desc = "Outline (floating nav)" },
    },
    opts = {
      backends = { ["_"] = { "treesitter" }, markdown = { "markdown" } },
      filter_kind = false,
      show_guides = true,
      layout = { default_direction = "right", min_width = 28 },
      on_attach = function(bufnr)
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Previous heading" })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next heading" })
      end,
    },
  },
}
