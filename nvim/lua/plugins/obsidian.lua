-- lua/plugins/obsidian.lua
-- Vault features: [[link]] completion, backlinks, tags, rename with link
-- updates, daily notes. Only active for files inside the workspace below;
-- other Markdown files keep the plain link following from core/markdown.lua.
return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    cmd = "Obsidian",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>nn", "<cmd>Obsidian new<CR>", desc = "New note" },
      { "<leader>nf", "<cmd>Obsidian quick_switch<CR>", desc = "Find note" },
      { "<leader>ns", "<cmd>Obsidian search<CR>", desc = "Search notes" },
      { "<leader>nb", "<cmd>Obsidian backlinks<CR>", desc = "Backlinks" },
      { "<leader>nl", "<cmd>Obsidian links<CR>", desc = "Links in this note" },
      { "<leader>nt", "<cmd>Obsidian tags<CR>", desc = "Tags" },
      { "<leader>nd", "<cmd>Obsidian today<CR>", desc = "Daily note (today)" },
      { "<leader>nr", "<cmd>Obsidian rename<CR>", desc = "Rename note (updates links)" },
      { "<leader>nc", "<cmd>Obsidian toggle_checkbox<CR>", desc = "Toggle checkbox" },
      { "<leader>np", "<cmd>Obsidian paste_img<CR>", desc = "Paste image" },
      { "<leader>no", "<cmd>Obsidian toc<CR>", desc = "Table of contents" },
    },
    -- A function so obsidian.builtin is only required once the plugin is loaded.
    opts = function()
      return {
        legacy_commands = false,
        workspaces = {
          { name = "firm", path = "~/projects/FIRM" },
        },
        picker = { name = "telescope.nvim" },
        -- New notes are named after their title instead of a timestamp id.
        note_id_func = require("obsidian.builtin").title_id,
        -- Do not rewrite id/aliases/tags frontmatter into notes on save.
        frontmatter = { enabled = false },
      }
    end,
    config = function(_, opts)
      require("obsidian").setup(opts)

      -- Completion comes from obsidian's in-process LSP; drive it with the
      -- built-in client instead of a completion plugin.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_obsidian_completion", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "obsidian-ls" then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
          end
        end,
      })
    end,
  },
}
