-- lua/plugins/session.lua
-- Per-directory sessions: reopen the notes and windows from last time.
return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session (this dir)" },
      { "<leader>qS", function() require("persistence").select() end, desc = "Pick session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save this session" },
    },
  },
}
