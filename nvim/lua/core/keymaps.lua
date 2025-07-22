local map = vim.keymap.set

-- track whether diagnostics are currently shown
local diagnostics_on = false
vim.diagnostic.disable()

--Mode navigation
vim.keymap.set("v", "<C-c>", "<Esc>")

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Horizontal split on <leader>s
map("n", "<leader>n", "<cmd>split<CR>", {
  desc = "Horizontal split",
})

-- Vertical split on <leader>d
map("n", "<leader>m", "<cmd>vsplit<CR>", {
  desc = "Vertical split",
})

-- 1) disable Ctrl-S in all modes (normal, insert, visual, term)
map({ "n","i","v","t" }, "<C-s>", "<Nop>", { silent = true, desc = "Disable Ctrl-S" })

-- 2) disable Ctrl-H everywhere except Normal (so only your <C-h> → window-left still works)
map({ "i","v","t","c","o" }, "<C-h>", "<Nop>", { silent = true, desc = "Disable Ctrl-H outside Normal" })

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
map("n", "<leader>bn", function()
  vim.cmd("edit " .. vim.fn.expand("~/notes"))
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

-- Restart all attached LSP servers
map("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "LSP: Restart servers" })


-- Epic Root dir Search
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
