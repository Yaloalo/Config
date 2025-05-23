return {
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      local oil = require("oil")

      oil.setup({
        default_file_explorer = true,
        skip_confirm_for_simple_edits = true,
        delete_to_trash = false,
        experimental_watch_for_changes = true,
        view_options = {
          show_hidden = true,
          is_hidden_file = function(name, _)
            return vim.startswith(name, ".")
          end,
        },
        use_default_keymaps = true,
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        win_options = {
          wrap = false,
          signcolumn = "no",
          cursorcolumn = false,
          foldcolumn = "0",
        },
      })

      -- Keymaps to open Oil
      vim.keymap.set("n", "<leader>oo", function()
        oil.open(vim.fn.getcwd())
      end, { desc = "󱎘 Oil Explorer (initial cwd)" })

      vim.keymap.set("n", "<leader>oc", function()
        local dir = vim.fn.expand("%:p:h")
        oil.open(dir)
      end, { desc = "󱎘 Oil Explorer (current file parent)" })

      -- Track original lines in oil:// buffer
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilEnter",
        callback = function(args)
          local bufnr = args.buf
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          vim.b[bufnr].oil_prev_lines = vim.deepcopy(lines)
        end,
      })

      -- Use Oil's save API instead of BufWritePre
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilSaved",
        callback = function(args)
          local bufnr = args.buf
          local old_lines = vim.b[bufnr].oil_prev_lines or {}
          local new_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

          local deleted = {}
          local seen = {}
          for _, line in ipairs(new_lines) do
            seen[line] = true
          end
          for _, line in ipairs(old_lines) do
            if not seen[line] and line ~= "" then
              table.insert(deleted, line)
            end
          end

          if #deleted > 0 then
            vim.ui.select({ "Yes", "No" }, {
              prompt = "Delete removed files from disk?",
            }, function(choice)
              if choice == "Yes" then
                local cwd = oil.get_current_dir()
                for _, filename in ipairs(deleted) do
                  local path = cwd .. "/" .. filename
                  if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
                    vim.fn.delete(path, "rf")
                    vim.notify("Deleted: " .. path, vim.log.levels.INFO)
                  end
                end
              end
            end)
          end
        end,
      })
    end,
  },
}
