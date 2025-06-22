-- lua/core/live_rg.lua
local M = {}
local ns = vim.api.nvim_create_namespace('LiveRG')

-- clear previous highlights
local function clear()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

-- run ripgrep synchronously and drop extmarks
local function run_rg(pattern)
  clear()
  if pattern == '' then return end

  -- run rg --json and collect lines
  local cmd = {
    'rg','--json',
    '--color=never','--no-heading','--column',
    '--smart-case',
    pattern,
    vim.fn.expand('%:p'),
  }
  local out = vim.fn.systemlist(cmd)

  for _, line in ipairs(out) do
    local ok, obj = pcall(vim.fn.json_decode, line)
    if ok and obj.type == 'match' then
      for _, sub in ipairs(obj.data.submatches) do
        local row = obj.data.line_number - 1
        local col = sub.start - 1
        vim.api.nvim_buf_set_extmark(0, ns, row, col, {
          end_col  = col + #sub.match.text,
          hl_group = 'Search',
        })
      end
    end
  end
end

-- hop to next/prev extmark
local function goto(dir)
  local cur = vim.api.nvim_win_get_cursor(0)
  local row0, col0 = cur[1]-1, cur[2]
  local marks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
  if dir ==  1 then
    for _, m in ipairs(marks) do
      local _, row, col = unpack(m)
      if row>row0 or (row==row0 and col>col0) then
        return vim.api.nvim_win_set_cursor(0, {row+1,col})
      end
    end
    if #marks>0 then
      local _, row, col = unpack(marks[1])
      vim.api.nvim_win_set_cursor(0, {row+1,col})
    end
  else
    for i=#marks,1,-1 do
      local _, row, col = unpack(marks[i])
      if row<row0 or (row==row0 and col<col0) then
        return vim.api.nvim_win_set_cursor(0, {row+1,col})
      end
    end
    if #marks>0 then
      local _, row, col = unpack(marks[#marks])
      vim.api.nvim_win_set_cursor(0, {row+1,col})
    end
  end
end

function M.start_live_rg()
  clear()
  -- get the pattern
  local pattern = vim.fn.input("RG ▶ ")
  if not pattern or pattern == '' then return end

  -- highlight matches
  run_rg(pattern)

  -- buffer-local n/N mappings
  vim.keymap.set('n','n', function() goto(1) end,
    { buffer=true, desc='Next RG match' })
  vim.keymap.set('n','N', function() goto(-1) end,
    { buffer=true, desc='Prev RG match' })
end

return M
