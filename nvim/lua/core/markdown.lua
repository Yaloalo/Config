-- lua/core/markdown.lua
-- Reading-oriented defaults for Markdown buffers and link following:
-- <CR> opens the link under the cursor, <BS> jumps back.
local api = vim.api

-- [[wiki|alias]], [text](target), <https://...>, bare URLs
local LINK_PATTERNS = {
  "%[%[([^%]]+)%]%]",
  "%[[^%]]*%]%(([^%)]+)%)",
  "<(%a[%w+.-]*://[^>]+)>",
  "(https?://[^%s%)%]>]+)",
}

local function link_under_cursor()
  local line = api.nvim_get_current_line()
  local col = api.nvim_win_get_cursor(0)[2] + 1
  for _, pattern in ipairs(LINK_PATTERNS) do
    local init = 1
    while true do
      local s, e, target = line:find(pattern, init)
      if not s then
        break
      end
      if col >= s and col <= e then
        return target
      end
      init = e + 1
    end
  end
end

local function slug(text)
  return (text:lower():gsub("[^%w%s%-_]", ""):gsub("%s", "-"))
end

local function jump_to_heading(anchor, same_file)
  local wanted = slug(anchor)
  for lnum, line in ipairs(api.nvim_buf_get_lines(0, 0, -1, false)) do
    local heading = line:match("^#+%s+(.-)%s*$")
    if heading and (slug(heading) == wanted or heading:lower() == anchor:lower()) then
      -- :edit already recorded the jump when the link pointed to another file.
      if same_file then
        vim.cmd("normal! m'")
      end
      api.nvim_win_set_cursor(0, { lnum, 0 })
      return
    end
  end
  vim.notify("Heading not found: " .. anchor, vim.log.levels.WARN)
end

local function resolve(path)
  local here = vim.fn.expand("%:p:h")
  local candidates = { path, path .. ".md" }
  for _, candidate in ipairs(candidates) do
    local full = vim.fs.normalize(vim.fs.joinpath(here, candidate))
    if vim.uv.fs_stat(full) then
      return full
    end
  end
  -- Wiki-style links resolve by file name anywhere in the repo.
  local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
  local name = vim.fs.basename(path)
  local found = vim.fs.find({ name, name .. ".md" }, { path = root, type = "file", limit = 1 })
  return found[1]
end

local function follow_link()
  local target = link_under_cursor()
  if not target then
    vim.cmd("normal! +")
    return
  end
  if target:match("^%a[%w+.-]*://") or target:match("^mailto:") then
    vim.ui.open(target)
    return
  end

  target = target:gsub("|.*$", ""):gsub("%s+\".*\"$", "")
  local path, anchor = target:match("^([^#]*)#?(.*)$")
  path = vim.uri_decode and vim.uri_decode(path) or path

  if path ~= "" then
    local file = resolve(path)
    if not file then
      vim.notify("Link target not found: " .. path, vim.log.levels.WARN)
      return
    end
    vim.cmd.edit(vim.fn.fnameescape(file))
  end
  if anchor ~= "" then
    jump_to_heading(anchor, path == "")
  end
end

api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("user_markdown", { clear = true }),
  pattern = "markdown",
  callback = function(args)
    local opt = vim.opt_local
    opt.wrap = true
    opt.linebreak = true
    opt.conceallevel = 2
    opt.foldmethod = "expr"
    opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    opt.foldlevel = 99

    local map = function(lhs, rhs, desc, extra)
      vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", { buffer = args.buf, desc = desc }, extra or {}))
    end
    -- Move by screen line through wrapped paragraphs.
    map("j", "v:count == 0 ? 'gj' : 'j'", "Down (screen line)", { expr = true })
    map("k", "v:count == 0 ? 'gk' : 'k'", "Up (screen line)", { expr = true })
    map("<CR>", follow_link, "Follow link")
    map("<BS>", "<C-o>", "Jump back")
  end,
})
