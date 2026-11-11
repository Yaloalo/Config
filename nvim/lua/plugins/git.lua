-- lua/plugins/git.lua
-- Gutter signs for git changes plus LazyGit for commit / push.
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      numhl = true,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("]c", function() gs.nav_hunk("next") end, "Next git change")
        map("[c", function() gs.nav_hunk("prev") end, "Previous git change")
        map("<leader>gp", gs.preview_hunk, "Preview change")
        map("<leader>gb", gs.blame_line, "Blame line")
        map("<leader>gd", gs.diffthis, "Diff against index")
      end,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
      local palette = require("core.palette")
      vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = palette.green })
      vim.api.nvim_set_hl(0, "GitSignsChange", { fg = palette.blue })
      vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = palette.red })
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitLog" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit (commit / push)" },
      { "<leader>gl", "<cmd>LazyGitLog<CR>", desc = "LazyGit log" },
    },
  },
}
