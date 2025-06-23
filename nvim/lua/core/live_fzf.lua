-- live_fzf.lua
-- Inline fuzzy search engine using swarn/fzy-lua (pure-Lua) for per-keystroke matching,
-- with custom navigation and in-buffer highlights.

local F   = {}
local api = vim.api
local fzy = require('fzy')  -- pure-Lua fzy implementation

-- Share highlight namespace with live_rg
F.ns      = api.nvim_create_namespace('live_rg_highlight')

-- Internal state: match positions and current index
F.matches = {}
F.cur     = 0

-- Clear highlights and reset state
function F.clear_highlights()
  api.nvim_buf_clear_namespace(0, F.ns, 0, -1)
  F.matches = {}
  F.cur     = 0
end

-- Inline fuzzy search using fzy.filter
-- @param raw string  the fuzzy query
function F.search_fuzzy(raw)
  F.clear_highlights()
  if raw == '' then return end

  -- Get all lines in the buffer
  local lines = api.nvim_buf_get_lines(0, 0, -1, false)
  -- Run fuzzy filter: returns {{idx, positions, score}, ...}
  local results = fzy.filter(raw, lines)

  -- Highlight and record each match
  for _, res in ipairs(results) do
    local idx, positions = res[1], res[2]
    if positions and #positions > 0 then
      local start = positions[1]
      local last  = positions[#positions] + 1
      table.insert(F.matches, { line = idx, col = start, end_col = last })
      api.nvim_buf_add_highlight(
        0, F.ns, 'Search',
        idx - 1, start - 1, last
      )
    end
  end

  -- Reset navigation pointer
  F.cur = 0
end

-- Jump to next match (wraps around)
-- @param count number of matches to advance (default 1)
function F.next(count)
  count = count or 1
  if #F.matches == 0 then return end
  F.cur = ((F.cur + count - 1) % #F.matches) + 1
  local m = F.matches[F.cur]
  api.nvim_win_set_cursor(0, { m.line, m.col - 1 })
  vim.cmd('normal! zz')
end

-- Jump to previous match (wraps around)
-- @param count number of matches to go back (default 1)
function F.prev(count)
  count = count or 1
  if #F.matches == 0 then return end
  F.cur = ((F.cur - count - 1) % #F.matches) + 1
  local m = F.matches[F.cur]
  api.nvim_win_set_cursor(0, { m.line, m.col - 1 })
  vim.cmd('normal! zz')
end

return F
