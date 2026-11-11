-- lua/plugins/treesitter.lua
-- nvim-treesitter `main` is the branch that targets Neovim 0.12. It only
-- installs parsers; highlighting is started per buffer below.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- Markdown itself plus the languages that commonly show up in code blocks.
    require("nvim-treesitter").install({
      "markdown", "markdown_inline", "bash", "c", "css", "diff", "html",
      "javascript", "json", "lua", "powershell", "python", "regex", "sql",
      "toml", "xml", "yaml",
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(args)
        -- No parser for this filetype -> keep regex highlighting.
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
