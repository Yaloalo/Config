local map = vim.keymap.set
map("n", "<leader>wq", "<cmd>close<CR>", { desc = "Close window" })
map("n", "<leader>ww", "<cmd>write<CR>", { desc = "Write file" })
for key, direction in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
  map("n", "<leader>w" .. key, "<C-w>" .. direction, { desc = "Focus window " .. key })
end

-- track whether diagnostics are currently shown
local diagnostics_on = false
vim.diagnostic.enable(false)

--Mode navigation
vim.keymap.set("v", "<C-c>", "<Esc>")

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Window actions live under Space W; standard Ctrl-N / Enter remain available.
map("n", "<leader>ws", "<cmd>split<CR>", {
  desc = "Horizontal split",
})

map("n", "<leader>wv", "<cmd>vsplit<CR>", {
  desc = "Vertical split",
})

-- Save without changing mode.
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR>", { silent = true, desc = "Save file" })


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


-- Epic Root dir Search
map("n", "<leader>sd", function()
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
