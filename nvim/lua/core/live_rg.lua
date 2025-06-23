-- live_rg.lua
-- A Neovim plugin for live-updating ripgrep-powered and inline-fuzzy searches

-- == Section: Module Initialization ==
local M = {}                    -- Plugin table
local api = vim.api             -- Neovim API alias for brevity
-- Add fzf-based inline fuzzy search helper
local fzf_search = require('core.live_fzf')

-- Create a namespace for our highlights
M.ns = api.nvim_create_namespace('live_rg_highlight')

-- Mode flag: false = ripgrep, true = inline fuzzy
M.fuzzy_mode = false


-- == Section: Highlight Management ==
--- Clear all existing ripgrep or fuzzy highlights in the current buffer
function M.clear_highlights()
  api.nvim_buf_clear_namespace(0, M.ns, 0, -1)
  -- Also clear fuzzy-specific namespace
  fzf_search.clear_highlights()
end


-- == Section: Ripgrep Search and Highlight ==
--- Run `rg --vimgrep` on the current file, highlight matches, and update search register
--- @param pat string  The ripgrep-style pattern to search for
function M.search(pat)
  M.clear_highlights()
  if pat == '' then return end

  local bufnr   = api.nvim_get_current_buf()
  local filename = vim.fn.expand('%:p')
  local cmd     = { 'rg', '--vimgrep', '--column', '--smart-case', pat, filename }

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, lines)
      for _, l in ipairs(lines) do
        if l ~= '' then
          local _, line, col = l:match('([^:]+):(%d+):(%d+):')
          local lnum      = tonumber(line) - 1
          local start_col = tonumber(col)   - 1
          local end_col   = start_col + #pat
          api.nvim_buf_add_highlight(bufnr, M.ns, 'Search', lnum, start_col, end_col)
        end
      end
      -- Sync native search register
      vim.fn.setreg('/', pat)
      vim.o.hlsearch = true
    end,
    on_stderr = function(_, err_lines)
      if err_lines then
        vim.notify(table.concat(err_lines, '\n'), vim.log.levels.ERROR)
      end
    end,
  })
end


-- == Section: Inline Fuzzy vs Ripgrep Dispatcher ==
--- Dispatch to either ripgrep or inline fuzzy based on mode
--- @param raw string  Raw user input
function M.do_search(raw)
  if M.fuzzy_mode then
    fzf_search.search_fuzzy(raw)
  else
    M.search(raw)
  end
end


-- == Section: Live Search Prompt ==
--- Open a floating prompt buffer for live search input
function M.live_search()
  local buf = api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.6)
  local height, row = 1, 2
  local col = math.floor((vim.o.columns - width) / 2)
  local win = api.nvim_open_win(buf, true, {
    style    = 'minimal', relative = 'editor',
    width    = width,     height   = height,
    row      = row,       col      = col,
    border   = 'rounded',
  })

  api.nvim_buf_set_option(buf, 'buftype', 'prompt')
  local prefix = M.fuzzy_mode and 'fz> ' or 'rg> '
  vim.fn.prompt_setprompt(buf, prefix)
  vim.cmd('startinsert!')

  api.nvim_buf_attach(buf, false, {
    on_lines = function()
      local line = api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ''
      local raw  = vim.trim(line:sub(#prefix + 1))
      M.do_search(raw)
    end,
  })

  local close = string.format('<Cmd>lua vim.api.nvim_win_close(%d, true)<CR>', win)
  for _, key in ipairs({ '<CR>', '<Esc>' }) do
    api.nvim_buf_set_keymap(buf, 'i', key, close, { nowait=true, noremap=true, silent=true })
  end
end


-- == Section: Mode Toggle and Keymaps ==
--- Toggle between ripgrep and inline fuzzy search modes
function M.toggle_mode()
  M.fuzzy_mode = not M.fuzzy_mode
  local mode = M.fuzzy_mode and 'Inline Fuzzy' or 'Ripgrep'
  vim.notify('Search mode: ' .. mode, vim.log.levels.INFO)
end

--- Setup function to map keys and integrate plugin
function M.setup()
  vim.keymap.set('n', '/', M.live_search, { noremap=true, silent=true, desc='Live RG/Fuzzy Search' })
  vim.keymap.set('n', '<leader>x', M.toggle_mode, { noremap=true, silent=true, desc='Toggle search mode' })
end


-- override n/N when in fuzzy mode
vim.keymap.set('n', 'n', function()
  if M.fuzzy_mode then
    require('core.live_fzf').next(vim.v.count1)
  else
    vim.cmd([[normal!]] .. vim.v.count1 .. 'n')
  end
end, { expr = false, silent = true })

vim.keymap.set('n', 'N', function()
  if M.fuzzy_mode then
    require('core.live_fzf').prev(vim.v.count1)
  else
    vim.cmd([[normal!]] .. vim.v.count1 .. 'N')
  end
end, { expr = false, silent = true })

return M
