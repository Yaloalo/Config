local M = {}

local ns = vim.api.nvim_create_namespace("fuzzyslash")
local augroup = vim.api.nvim_create_augroup("fuzzyslash", { clear = true })

local config = {
  prompt = "fuzzy/",
  smart_case = true,
  min_query = 1,
  move_cursor = true,
  highlight = {
    match = "FuzzySlashMatch",
    current = "FuzzySlashCurrent",
  },
}

local state = {
  active = false,
  bufnr = nil,
  win = nil,
  matches = {},
  idx = 0,
  query = "",
  prev_maps = {},
}

local function ensure_highlights()
  if vim.fn.hlexists(config.highlight.match) == 0 then
    vim.api.nvim_set_hl(0, config.highlight.match, { link = "Search" })
  end
  if vim.fn.hlexists(config.highlight.current) == 0 then
    vim.api.nvim_set_hl(0, config.highlight.current, { link = "IncSearch" })
  end
end

local function clear_namespace()
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    vim.api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
  end
end

local function restore_keymap(lhs, saved)
  if not saved then
    return
  end
  local opts = {
    buffer = state.bufnr,
    silent = saved.silent == 1,
    expr = saved.expr == 1,
    noremap = saved.noremap == 1,
    nowait = saved.nowait == 1,
    desc = saved.desc,
  }
  if saved.callback then
    vim.keymap.set("n", lhs, saved.callback, opts)
  elseif saved.rhs then
    vim.keymap.set("n", lhs, saved.rhs, opts)
  end
end

local function capture_keymap(lhs)
  if not state.bufnr then
    return nil
  end
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(state.bufnr, "n")) do
    if map.lhs == lhs then
      return map
    end
  end
  return nil
end

local function clear_keymaps()
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    pcall(vim.keymap.del, "n", "n", { buffer = state.bufnr })
    pcall(vim.keymap.del, "n", "N", { buffer = state.bufnr })
    restore_keymap("n", state.prev_maps.n)
    restore_keymap("N", state.prev_maps.N)
  end
  state.prev_maps = {}
end

local function contains_uppercase(str)
  return str:lower() ~= str
end

local function fuzzy_positions(line, query)
  if query == "" or #query < config.min_query then
    return nil
  end

  local search_line = line
  local search_query = query
  if config.smart_case and not contains_uppercase(query) then
    search_line = line:lower()
    search_query = query:lower()
  end

  local positions = {}
  local from = 1
  for i = 1, #search_query do
    local ch = search_query:sub(i, i)
    local found = search_line:find(ch, from, true)
    if not found then
      return nil
    end
    positions[#positions + 1] = found
    from = found + 1
  end
  return positions
end

local function find_matches(bufnr, query)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return {}
  end
  local matches = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    local pos = fuzzy_positions(line, query)
    if pos then
      local start_col = pos[1] - 1
      local end_col = pos[#pos] -- exclusive for extmark
      matches[#matches + 1] = { lnum = i - 1, col = start_col, end_col = end_col }
    end
  end
  return matches
end

local function echo_status(text, hl)
  vim.api.nvim_echo({ { text, hl or "None" } }, false, {})
  vim.cmd("redraw")
end

local function render_highlights()
  clear_namespace()
  if not (state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)) then
    return
  end
  for i, match in ipairs(state.matches) do
    local group = (i == state.idx) and config.highlight.current or config.highlight.match
    vim.api.nvim_buf_set_extmark(state.bufnr, ns, match.lnum, match.col, {
      end_col = match.end_col,
      hl_group = group,
      priority = 200,
    })
  end
end

local function jump_to(idx, opts)
  if not (state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)) then
    return
  end
  if #state.matches == 0 then
    return
  end
  state.idx = idx
  local target = state.matches[state.idx]
  if not target then
    return
  end
  render_highlights()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    vim.api.nvim_win_set_cursor(state.win, { target.lnum + 1, target.col })
  else
    vim.api.nvim_win_set_cursor(0, { target.lnum + 1, target.col })
  end
  if opts and opts.center then
    pcall(vim.cmd, "normal! zz")
  end
  echo_status(string.format("[fuzzy %d/%d] %s", state.idx, #state.matches, state.query))
end

local function update_matches(query, move_cursor)
  state.query = query
  if query == "" or #query < config.min_query then
    state.matches = {}
    state.idx = 0
    render_highlights()
    echo_status(config.prompt, "Question")
    return
  end

  state.matches = find_matches(state.bufnr, query)
  if #state.matches == 0 then
    state.idx = 0
    render_highlights()
    echo_status("[no fuzzy matches]", "WarningMsg")
    return
  end
  state.idx = math.max(1, math.min(state.idx, #state.matches))
  render_highlights()
  if move_cursor and config.move_cursor then
    jump_to(state.idx, { center = false })
  else
    echo_status(string.format("[fuzzy %d/%d] %s", state.idx, #state.matches, query))
  end
end

local function attach_keymaps()
  if not (state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)) then
    return
  end
  state.prev_maps.n = state.prev_maps.n or capture_keymap("n")
  state.prev_maps.N = state.prev_maps.N or capture_keymap("N")
  vim.keymap.set("n", "n", function()
    M.next()
  end, { buffer = state.bufnr, silent = true, desc = "Next fuzzy match" })
  vim.keymap.set("n", "N", function()
    M.prev()
  end, { buffer = state.bufnr, silent = true, desc = "Previous fuzzy match" })
end

local function stop_autocmds()
  if state.bufnr then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = state.bufnr })
  end
end

local function start_autocmds()
  if not (state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)) then
    return
  end
  vim.api.nvim_clear_autocmds({ group = augroup, buffer = state.bufnr })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = augroup,
    buffer = state.bufnr,
    callback = function()
      if state.active and state.query ~= "" then
        update_matches(state.query, false)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = augroup,
    buffer = state.bufnr,
    callback = function()
      M.stop(true)
    end,
  })
end

local function finalize(query)
  if query == "" or #query < config.min_query then
    M.stop(true)
    return
  end
  state.active = true
  attach_keymaps()
  start_autocmds()
  update_matches(query, true)
end

local function prompt()
  local query = ""
  echo_status(config.prompt, "Question")
  while true do
    local char = vim.fn.getcharstr()
    if char == "\027" or char == "\003" then -- Esc or Ctrl-C
      M.stop(true)
      return
    elseif char == "\r" then
      finalize(query)
      return
    elseif char == "\b" or char == "\127" then
      query = query:sub(1, -2)
    elseif char == "\014" then -- Ctrl-L clears
      query = ""
    else
      query = query .. char
    end
    state.idx = 1
    update_matches(query, true)
  end
end

function M.start()
  if state.active then
    M.stop(true)
  end
  state.bufnr = vim.api.nvim_get_current_buf()
  state.win = vim.api.nvim_get_current_win()
  state.matches = {}
  state.idx = 0
  state.query = ""
  state.active = false
  state.prev_maps = {}
  ensure_highlights()
  prompt()
end

function M.stop(silent)
  clear_namespace()
  clear_keymaps()
  stop_autocmds()
  state.active = false
  state.matches = {}
  state.idx = 0
  state.query = ""
  if not silent then
    echo_status("Fuzzy search cleared")
  else
    vim.api.nvim_echo({}, false, {})
  end
end

function M.next()
  if not state.active or #state.matches == 0 then
    echo_status("[no fuzzy search active]", "WarningMsg")
    return
  end
  local next_idx = state.idx + 1
  if next_idx > #state.matches then
    next_idx = 1
  end
  jump_to(next_idx, { center = true })
end

function M.prev()
  if not state.active or #state.matches == 0 then
    echo_status("[no fuzzy search active]", "WarningMsg")
    return
  end
  local prev_idx = state.idx - 1
  if prev_idx < 1 then
    prev_idx = #state.matches
  end
  jump_to(prev_idx, { center = true })
end

function M.status()
  if not state.active or state.query == "" then
    return ""
  end
  if #state.matches == 0 then
    return "[0/0]"
  end
  return string.format("[%d/%d]", state.idx, #state.matches)
end

function M.setup(opts)
  if opts then
    config = vim.tbl_deep_extend("force", config, opts)
  end
  ensure_highlights()
end

return M
