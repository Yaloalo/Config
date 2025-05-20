-- lua/core/keymaps.lua

local map = vim.keymap.set

-- track whether diagnostics are currently shown
local diagnostics_on = true

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Window navigation
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })

-- In insert mode: move cursor with Ctrl+hjkl
map("i", "<C-h>", "<Left>")
map("i", "<C-j>", "<Down>")
map("i", "<C-k>", "<Up>")
map("i", "<C-l>", "<Right>")

-- Open notes
map("n", "<leader>n", function()
  vim.cmd("edit " .. vim.fn.expand("~/documents/Main"))
end, { desc = "Open notes" })

-- Toggle all LSP diagnostics on/off
map("n", "<leader>lt", function()
  if diagnostics_on then
    vim.diagnostic.disable()
    vim.notify("Diagnostics OFF", vim.log.levels.WARN)
  else
    vim.diagnostic.enable()
    vim.notify("Diagnostics ON", vim.log.levels.INFO)
  end
  diagnostics_on = not diagnostics_on
end, { desc = "Toggle LSP Diagnostics" })

-- Show LSP Documentation for a function
map("n", "<leader>ld", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation" })

-- Close the current window/buffer with <leader>c
map("n", "<leader>c", "<cmd>q<CR>", { desc = "Close window" })

map("n", "<leader>w", function()
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  require("telescope.builtin").find_files({
    prompt_title = "Find Directory (fd)",
    cwd = "/",
    find_command = { "fd", "-t", "d", "--hidden", "--no-ignore" },
    attach_mappings = function(prompt_bufnr, map_)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local dir = entry.value
        if not dir:match("^/") then
          dir = "/" .. dir
        end
        vim.cmd("cd " .. vim.fn.fnameescape(dir))
        vim.notify("cwd → " .. vim.fn.getcwd(), vim.log.levels.INFO)
      end)
      return true
    end,
  })
end, { desc = "Fuzzy-find directory from / and cd" })
