-- lua/core/keymenu.lua
-- Keybinding browser: plugins → their keybindings → details.
-- <Right>/<CR>/l goes one level deeper, <Left>/h goes back.
--
-- A mapping is attributed to a plugin from, in order:
--   1. lazy.nvim `keys` specs,
--   2. where the mapping was created (recorded by M.track, which wraps
--      vim.keymap.set and must run before any mappings are defined),
--   3. where its Lua callback is defined.
local M = {}

local MODES = { "n", "x" }
local MODE_NAMES = { n = "normal", x = "visual" }
local CONFIG = vim.fs.normalize(vim.fn.stdpath("config"))
local LAZY_ROOT = vim.fs.normalize(vim.fn.stdpath("data") .. "/lazy") .. "/"

-- [mode .. lhs] = { plugin?, where?, file, line }
local origins = {}

local function key_id(mode, lhs)
  return mode .. vim.keycode(lhs)
end

-- Mode names as written in definitions → modes reported by nvim_get_keymap.
local function expand_modes(mode)
  local out = {}
  for _, m in ipairs(type(mode) == "table" and mode or { mode or "n" }) do
    if m == "v" then
      vim.list_extend(out, { "x", "s" })
    elseif m == "" then
      vim.list_extend(out, { "n", "x", "o" })
    else
      table.insert(out, m)
    end
  end
  return out
end

-- Returns plugin name, or nil plus a location tag ("plugins.x", "core.x", "lazy").
local function locate(source)
  if not source or source:sub(1, 1) ~= "@" then
    return nil
  end
  local path = vim.fs.normalize(source:sub(2))
  if vim.startswith(path, LAZY_ROOT) then
    local name = path:sub(#LAZY_ROOT + 1):match("^([^/]+)/")
    if name == "lazy.nvim" then
      return nil, "lazy"
    end
    return name
  end
  local file = path:match("^" .. vim.pesc(CONFIG) .. "/lua/(%w+/[^/]+)%.lua$")
  if file then
    return nil, file:gsub("/", ".")
  end
end

-- Walk the call stack of a vim.keymap.set call. A plugin frame wins (e.g.
-- gitsigns calling our on_attach); crossing lazy.nvim's loader ends the walk
-- so a plugin that merely triggered a lazy load is not blamed. Mappings that
-- lazy.nvim creates itself come from `keys` specs and are resolved there.
local function find_origin()
  local first
  for level = 3, 40 do
    local info = debug.getinfo(level, "Sl")
    if not info then
      break
    end
    local plugin, where = locate(info.source)
    if plugin then
      first = first or { file = info.source:sub(2), line = info.currentline }
      return { plugin = plugin, file = first.file, line = first.line }
    elseif where == "lazy" then
      if not first then
        return nil
      end
      break
    elseif where and not first then
      first = { where = where, file = info.source:sub(2), line = info.currentline }
    end
  end
  return first
end

function M.track()
  local set = vim.keymap.set
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.keymap.set = function(mode, lhs, rhs, opts)
    local origin = find_origin()
    if origin then
      for _, m in ipairs(expand_modes(mode)) do
        origins[key_id(m, lhs)] = origin
      end
    end
    return set(mode, lhs, rhs, opts)
  end
end

local function plugins_in_file(module)
  local ok, spec = pcall(require, module)
  if not ok or type(spec) ~= "table" then
    return {}
  end
  if type(spec[1]) == "string" or spec.dir then
    spec = { spec }
  end
  local names = {}
  for _, s in ipairs(spec) do
    if type(s) == "table" and (s.name or s[1]) then
      table.insert(names, s.name or s[1]:match("[^/]+$"))
    end
  end
  return names
end

local spec_files
local function spec_file(plugin)
  if not spec_files then
    spec_files = {}
    for _, path in ipairs(vim.fn.glob(CONFIG .. "/lua/plugins/*.lua", false, true)) do
      for _, name in ipairs(plugins_in_file("plugins." .. vim.fn.fnamemodify(path, ":t:r"))) do
        spec_files[name] = path
      end
    end
  end
  return spec_files[plugin]
end

local function group_name(plugin, where)
  if plugin then
    return plugin
  elseif where and vim.startswith(where, "plugins.") then
    local names = plugins_in_file(where)
    return #names > 0 and table.concat(names, " + ") or where
  elseif where and vim.startswith(where, "core.") then
    return "Config: " .. where:sub(6)
  end
  return "Neovim built-in"
end

local function spec_index()
  local index = {}
  local Keys = require("lazy.core.handler.keys")
  local Plugin = require("lazy.core.plugin")
  for _, plugin in ipairs(require("lazy").plugins()) do
    for _, key in pairs(Keys.resolve(Plugin.values(plugin, "keys", true))) do
      for _, m in ipairs(expand_modes(key.mode)) do
        index[key_id(m, key.lhs)] = { plugin = plugin.name, key = key }
      end
    end
  end
  return index
end

local function collect(buf)
  local index = spec_index()
  local groups, by_name, by_key = {}, {}, {}

  for _, mode in ipairs(MODES) do
    local maps = vim.list_extend(vim.api.nvim_buf_get_keymap(buf, mode), vim.api.nvim_get_keymap(mode))
    for _, map in ipairs(maps) do
      local raw = vim.keycode(map.lhs)
      local lhs = vim.fn.keytrans(raw):gsub("<NL>", "<C-J>")
      local desc = map.desc or ""
      if
        not (
          lhs:find("<Plug>", 1, true)
          or lhs:find("<SNR>", 1, true)
          or desc == "which_key_ignore"
          or vim.startswith(desc, "which-key-trigger")
        )
      then
        local id = mode .. raw
        local spec = index[id]
        local origin = origins[id]
        local plugin, where
        if spec then
          plugin = spec.plugin
        elseif origin then
          plugin, where = origin.plugin, origin.where
        elseif map.callback then
          plugin, where = locate(debug.getinfo(map.callback, "S").source)
        end

        local name = group_name(plugin, where)
        desc = map.desc or (map.rhs ~= "" and map.rhs) or "(no description)"
        local key = table.concat({ name, lhs, desc, map.buffer }, "\0")
        local item = by_key[key]
        if item then
          table.insert(item.modes, mode)
        else
          item = {
            lhs = lhs,
            modes = { mode },
            desc = desc,
            rhs = map.rhs,
            callback = map.callback,
            buffer = map.buffer ~= 0,
            group = name,
            spec = spec and spec.key,
            origin = origin,
          }
          by_key[key] = item
          if not by_name[name] then
            by_name[name] = { name = name, maps = {} }
            table.insert(groups, by_name[name])
          end
          table.insert(by_name[name].maps, item)
        end
      end
    end
  end

  -- Plugins alphabetically, then own config, then Neovim's defaults.
  local function rank(g)
    return (g.name == "Neovim built-in" and 2) or (vim.startswith(g.name, "Config:") and 1) or 0
  end
  table.sort(groups, function(a, b)
    if rank(a) ~= rank(b) then
      return rank(a) < rank(b)
    end
    return a.name:lower() < b.name:lower()
  end)
  for i, g in ipairs(groups) do
    g.index = i
    table.sort(g.maps, function(a, b)
      return a.lhs:lower() < b.lhs:lower()
    end)
    for j, item in ipairs(g.maps) do
      item.index = j
    end
  end
  return groups
end

local function short(path)
  return (path:gsub("^" .. vim.pesc(vim.env.HOME), "~"))
end

local function details(item)
  local lines = { "# " .. item.desc, "" }
  local modes = vim.tbl_map(function(m) return MODE_NAMES[m] or m end, item.modes)
  table.insert(lines, "- **Keys:** `" .. item.lhs .. "`")
  table.insert(lines, "- **Mode:** " .. table.concat(modes, ", "))
  table.insert(lines, "- **From:** " .. item.group .. (item.buffer and " (only in this buffer)" or ""))

  -- lazy.nvim installs a loader stub until the plugin loads; the spec holds
  -- the real action.
  local rhs, fn = item.rhs, item.callback
  if item.spec and item.spec.rhs then
    if type(item.spec.rhs) == "function" then
      fn, rhs = item.spec.rhs, nil
    else
      fn, rhs = nil, item.spec.rhs
    end
  end
  if rhs and rhs ~= "" then
    table.insert(lines, "- **Runs:** `" .. rhs .. "`")
  end

  local info = fn and debug.getinfo(fn, "S")
  local file = info and info.source:sub(1, 1) == "@" and info.source:sub(2)
  if file then
    table.insert(lines, "- **Defined in:** `" .. short(file) .. ":" .. info.linedefined .. "`")
  elseif item.origin then
    table.insert(lines, "- **Defined in:** `" .. short(item.origin.file) .. ":" .. item.origin.line .. "`")
  elseif item.spec and spec_file(item.group) then
    table.insert(lines, "- **Configured in:** `" .. short(spec_file(item.group)) .. "`")
  end

  if file and vim.uv.fs_stat(file) and info.linedefined > 0 then
    local last = math.min(info.lastlinedefined, info.linedefined + 30)
    local code = vim.list_slice(vim.fn.readfile(file, "", last), info.linedefined, last)
    vim.list_extend(lines, { "", "## Code", "", "```lua" })
    vim.list_extend(lines, code)
    if last < info.lastlinedefined then
      table.insert(lines, "-- …")
    end
    table.insert(lines, "```")
  end
  return lines
end

local function show_details(item, back)
  local lines = details(item)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = math.floor(vim.o.columns * 0.7)
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " " .. item.group .. " ",
    title_pos = "center",
    footer = " ← back · q close ",
    footer_pos = "center",
  })
  vim.wo[win].wrap = true

  local function close(go_back)
    return function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if go_back then
        back()
      end
    end
  end
  for _, lhs in ipairs({ "<Left>", "h", "<BS>" }) do
    vim.keymap.set("n", lhs, close(true), { buffer = buf, nowait = true })
  end
  for _, lhs in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", lhs, close(false), { buffer = buf, nowait = true })
  end
end

local function pick(opts)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local theme = require("telescope.themes").get_dropdown({
    previewer = false,
    layout_config = { width = 0.7, height = 0.75 },
  })

  require("telescope.pickers").new(theme, {
    prompt_title = opts.title,
    results_title = opts.hint,
    default_selection_index = opts.selection,
    finder = require("telescope.finders").new_table({
      results = opts.items,
      entry_maker = function(item)
        local text = opts.display(item)
        return { value = item, display = text, ordinal = text }
      end,
    }),
    sorter = require("telescope.config").values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local function right()
        local entry = action_state.get_selected_entry()
        if entry then
          actions.close(prompt_bufnr)
          opts.on_right(entry.value)
        end
      end
      map({ "i", "n" }, "<Right>", right)
      map({ "i", "n" }, "<CR>", right)
      map("n", "l", right)
      if opts.on_left then
        local function left()
          actions.close(prompt_bufnr)
          opts.on_left()
        end
        map({ "i", "n" }, "<Left>", left)
        map("n", "h", left)
      end
      return true
    end,
  }):find()
end

function M.open()
  local groups = collect(vim.api.nvim_get_current_buf())
  local show_groups, show_maps

  show_groups = function(selection)
    pick({
      title = "Keybindings",
      hint = "→ open · type to filter",
      items = groups,
      selection = selection,
      display = function(g)
        return string.format("%-40s %3d", g.name, #g.maps)
      end,
      on_right = function(g)
        show_maps(g)
      end,
    })
  end

  show_maps = function(group, selection)
    pick({
      title = group.name,
      hint = "→ details · ← back",
      items = group.maps,
      selection = selection,
      display = function(item)
        return string.format("%-18s %-4s %s", item.lhs, table.concat(item.modes), item.desc)
      end,
      on_right = function(item)
        show_details(item, function()
          show_maps(group, item.index)
        end)
      end,
      on_left = function()
        show_groups(group.index)
      end,
    })
  end

  show_groups(1)
end

return M
