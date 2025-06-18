-- ~/.config/nvim/lua/plugins/ufo.lua
return {
--[[
    {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      -- 1) Persist manual folds across sessions
      vim.opt.viewoptions = "folds,cursor,curdir,slash,unix"
      vim.api.nvim_create_autocmd("BufWinLeave", {
        pattern = "*",
        command = "silent! mkview",
      })
      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "*",
        command = "silent! loadview",
      })

      -- 2) Fold indicators in the foldcolumn
      vim.o.foldcolumn     = "1"    -- show a 1-char fold indicator on the left
      vim.o.foldlevel      = 99     -- start with all folds open
      vim.o.foldlevelstart = 99     -- keep them open on buffer load
      vim.o.foldenable     = true   -- enable folding


        -- try LSP first, then Treesitter, then indent
        return require("ufo").getFolds(bufnr, "lsp")
          :catch(function(err)
            return handleFallbackException(err, "treesitter")
          end)
          :catch(function(err)
            return handleFallbackException(err, "indent")
          end)
      end

      require("ufo").setup({
        provider_selector = function(bufnr, filetype, buftype)
          return customizeSelector
        end,
      })

      -- 4) Key mappings
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- <C-b>: Close all folds
      map({ "n", "i" }, "<C-b>", function()
        require("ufo").closeAllFolds()
      end, opts)
      -- <C-v>: Open all folds
      map({ "n", "i" }, "<C-v>", function()
        require("ufo").openAllFolds()
      end, opts)
      -- <C-o>: Open fold under cursor
      map({ "n", "i" }, "<C-o>", function()
        vim.cmd("silent! normal! zo")
      end, opts)
      -- <C-p>: Close fold under cursor
      map({ "n", "i" }, "<C-p>", function()
        vim.cmd("silent! normal! zc")
      end, opts)
      -- <C-f> in Visual: Create a manual fold
      map("v", "<C-f>", function()
        vim.cmd("silent! normal! zf")
      end, opts)
    end,
  },
--]]
}
