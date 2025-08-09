return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      base = "HEAD",            -- compare to last commit
      word_diff = true,         -- intraline highlights
      watch_gitdir = { follow_files = true },
    },
  },
}

