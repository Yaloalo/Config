-- ~/.config/nvim/lua/plugins/comment.lua
return {
  {
    "numToStr/Comment.nvim",
    dependencies = {
      -- Treesitter-aware commentstring for TSX/JSX/Svelte/etc.
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      padding = true,
      sticky = true,
      mappings = { basic = true, extra = true }, -- keep gcc/gc/... defaults
      -- Use Treesitter to pick correct commentstring in mixed-language files
      pre_hook = function(ctx)
        local ok, integration = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
        if ok then
          return integration.create_pre_hook()(ctx)
        end
      end,
      post_hook = nil,
    },
    config = function(_, opts)
      require("Comment").setup(opts)

      -- Reasonable convenience keybinding: Ctrl-/ toggles line comments
      -- Works in most terminals as <C-_>. Keep plugin defaults (gcc/gc/gb...) too.
      local api = require("Comment.api")

      -- Normal mode: toggle current line
      vim.keymap.set("n", "<C-_>", api.toggle.linewise.current, { desc = "Comment: toggle line" })
      vim.keymap.set("n", "<C-/>", api.toggle.linewise.current, { desc = "Comment: toggle line (alt)" })

      -- Visual mode: toggle selection
      vim.keymap.set("x", "<C-_>", function()
        api.toggle.linewise(vim.fn.visualmode())
      end, { desc = "Comment: toggle selection" })
      vim.keymap.set("x", "<C-/>", function()
        api.toggle.linewise(vim.fn.visualmode())
      end, { desc = "Comment: toggle selection (alt)" })
    end,
  },
}

