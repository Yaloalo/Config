-- lua/core/oil_sidebar.lua
-- Edit mode for the file tree. <Tab> in Neo-tree swaps the sidebar for an
-- Oil buffer of the directory under the cursor; <Tab> in Oil swaps back.
-- In Oil, type lines to create (`notes/`, `notes/new.md`, `a/b/c.md`), edit
-- names to rename, delete lines to delete, then :w / <C-s> to apply.
local M = {}

local WIDTH = 34

local function sidebar_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.w[win].oil_sidebar then
      return win
    end
  end
end

-- The window files should open in: first normal, non-sidebar window.
local function main_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not vim.w[win].oil_sidebar and vim.api.nvim_win_get_config(win).relative == "" and vim.bo[buf].buftype == "" then
      return win
    end
  end
end

function M.is_open()
  return sidebar_win() ~= nil
end

function M.open(dir)
  vim.cmd("Neotree close")
  local win = sidebar_win()
  if not win then
    vim.cmd("topleft vsplit")
    win = vim.api.nvim_get_current_win()
    vim.w[win].oil_sidebar = true
    vim.wo[win].winfixwidth = true
    vim.api.nvim_win_set_width(win, WIDTH)
  end
  vim.api.nvim_set_current_win(win)
  require("oil").open(dir)
end

function M.close()
  local win = sidebar_win()
  if not win then
    return true
  end
  if vim.bo[vim.api.nvim_win_get_buf(win)].modified then
    vim.notify("Oil: unsaved changes — :w to apply or :e! to discard", vim.log.levels.WARN)
    return false
  end
  if #vim.api.nvim_tabpage_list_wins(0) == 1 then
    vim.cmd("vnew")
  end
  vim.api.nvim_win_close(win, false)
  return true
end

-- Back to navigation: Neo-tree with the entry under the Oil cursor revealed.
function M.to_tree()
  local oil = require("oil")
  local dir, entry = oil.get_current_dir(), oil.get_cursor_entry()
  if vim.w.oil_sidebar and not M.close() then
    return
  end
  local target = dir and (entry and dir .. entry.name or dir:gsub("/$", ""))
  require("neo-tree.command").execute({
    action = "focus",
    position = "left",
    reveal_file = target,
    reveal_force_cwd = false,
  })
end

-- <CR> in the sidebar: directories open in place, files in the main window.
function M.select()
  local oil = require("oil")
  local entry = oil.get_cursor_entry()
  if not vim.w.oil_sidebar or not entry or entry.type == "directory" then
    return oil.select()
  end
  local path = oil.get_current_dir() .. entry.name
  local win = main_win()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("botright vsplit")
  end
  vim.cmd.edit(vim.fn.fnameescape(path))
end

return M
