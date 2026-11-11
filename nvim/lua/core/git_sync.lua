-- lua/core/git_sync.lua
-- Quick commit / pull / push for the repo of the current working directory,
-- plus statusline markers: REMOTE = remote commits not pulled yet, LOCAL
-- COMMITS = local commits not pushed, UNCOMMITTED = files with uncommitted
-- changes in the repo, FILE = this file is uncommitted / new. The remote is fetched
-- in the background every few minutes and when Neovim regains focus; the
-- local status is re-read on save and after git / file operations.
local M = {}

local FETCH_INTERVAL = 5 * 60 * 1000
local FETCH_MIN_GAP = 60 * 1000
-- Never hang on a password or passphrase prompt in the background.
local ENV = { GIT_TERMINAL_PROMPT = "0", GIT_SSH_COMMAND = "ssh -o BatchMode=yes" }

M.ahead, M.behind = 0, 0
-- [absolute path] = porcelain status code ("M ", "??", ...)
M.changed, M.changed_count = {}, 0
local fetching, last_fetch = false, 0

local function root()
  return vim.fs.root(vim.fn.getcwd(), ".git")
end

local function git(args, cwd, on_done)
  vim.system(vim.list_extend({ "git" }, args), { cwd = cwd, text = true, env = ENV }, function(res)
    vim.schedule(function()
      on_done(res)
    end)
  end)
end

local function report(title, res)
  local output = vim.trim((res.stdout or "") .. "\n" .. (res.stderr or ""))
  local level = res.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
  vim.notify(title .. (output ~= "" and "\n" .. output or ""), level, { title = "git" })
end

local function update_counts(cwd)
  git({ "rev-list", "--left-right", "--count", "HEAD...@{upstream}" }, cwd, function(res)
    local ahead, behind = (res.stdout or ""):match("(%d+)%s+(%d+)")
    M.ahead, M.behind = tonumber(ahead) or 0, tonumber(behind) or 0
    vim.cmd.redrawstatus()
  end)
end

function M.refresh_status()
  local cwd = root()
  if not cwd then
    M.changed, M.changed_count = {}, 0
    return
  end
  git({ "status", "--porcelain=v1", "-z", "--untracked-files=all" }, cwd, function(res)
    local changed, count = {}, 0
    local entries = vim.split(res.stdout or "", "\0", { trimempty = true })
    local i = 1
    while i <= #entries do
      local code, path = entries[i]:sub(1, 2), entries[i]:sub(4)
      changed[vim.fs.normalize(cwd .. "/" .. path)] = code
      count = count + 1
      -- Renames and copies are followed by the original path.
      i = i + (code:find("[RC]") and 2 or 1)
    end
    M.changed, M.changed_count = changed, count
    vim.cmd.redrawstatus()
  end)
end

-- fetch = false only recounts against the last fetched state.
function M.refresh(fetch)
  local cwd = root()
  if not cwd then
    M.ahead, M.behind = 0, 0
    M.refresh_status()
    return
  end
  M.refresh_status()
  local now = vim.uv.now()
  if fetch == false or fetching or now - last_fetch < FETCH_MIN_GAP then
    return update_counts(cwd)
  end
  fetching, last_fetch = true, now
  git({ "fetch", "--quiet" }, cwd, function()
    fetching = false
    update_counts(cwd)
  end)
end

function M.statusline_behind()
  return M.behind > 0 and ("REMOTE: " .. M.behind) or ""
end

function M.statusline_ahead()
  return M.ahead > 0 and ("LOCAL COMMITS: " .. M.ahead) or ""
end

function M.statusline_repo()
  return M.changed_count > 0 and ("UNCOMMITTED: " .. M.changed_count) or ""
end

function M.statusline_file()
  local code = M.changed[vim.fs.normalize(vim.api.nvim_buf_get_name(0))]
  if not code then
    return ""
  end
  return code == "??" and "FILE: NEW" or "FILE: UNCOMMITTED"
end

-- Write modified files of this repo so the commit contains what is on screen.
-- Only real files: writing an Oil buffer would apply file operations.
local function write_repo_buffers(cwd)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.startswith(name, cwd .. "/") then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent write")
      end)
    end
  end
end

function M.commit()
  local cwd = root()
  if not cwd then
    return vim.notify("Not inside a git repository", vim.log.levels.WARN)
  end
  write_repo_buffers(cwd)
  git({ "status", "--porcelain" }, cwd, function(status)
    local changes = vim.trim(status.stdout or "")
    if changes == "" then
      return vim.notify("Nothing to commit", vim.log.levels.INFO, { title = "git" })
    end
    local count = #vim.split(changes, "\n")
    vim.ui.input({ prompt = ("Commit %d changed file(s), message: "):format(count) }, function(msg)
      if not msg or vim.trim(msg) == "" then
        return
      end
      git({ "add", "--all" }, cwd, function(add)
        if add.code ~= 0 then
          return report("git add failed", add)
        end
        git({ "commit", "--message", msg }, cwd, function(res)
          report(res.code == 0 and "Committed" or "Commit failed", res)
          M.refresh(false)
        end)
      end)
    end)
  end)
end

function M.pull(on_success)
  local cwd = root()
  if not cwd then
    return vim.notify("Not inside a git repository", vim.log.levels.WARN)
  end
  vim.notify("Pulling…", vim.log.levels.INFO, { title = "git" })
  git({ "pull", "--rebase", "--autostash" }, cwd, function(res)
    if res.code ~= 0 then
      report("Pull failed — resolve in LazyGit (<leader>gg)", res)
    else
      report("Pulled", res)
      vim.cmd("checktime") -- reload buffers changed by the pull
      if on_success then
        on_success()
      end
    end
    M.refresh(false)
  end)
end

function M.push()
  local cwd = root()
  if not cwd then
    return vim.notify("Not inside a git repository", vim.log.levels.WARN)
  end
  git({ "push" }, cwd, function(res)
    report(res.code == 0 and "Pushed" or "Push failed", res)
    M.refresh(false)
  end)
end

function M.setup()
  local timer = assert(vim.uv.new_timer())
  timer:start(FETCH_INTERVAL, FETCH_INTERVAL, vim.schedule_wrap(M.refresh))
  local group = vim.api.nvim_create_augroup("user_git_sync", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "DirChanged" }, {
    group = group,
    callback = function()
      M.refresh()
    end,
  })
  -- Local changes: saves, Oil file operations, closing LazyGit.
  vim.api.nvim_create_autocmd({ "BufWritePost", "TermClose" }, {
    group = group,
    callback = function()
      M.refresh_status()
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OilActionsPost",
    callback = function()
      M.refresh_status()
    end,
  })

  local map = vim.keymap.set
  map("n", "<leader>gc", M.commit, { desc = "Commit all changes" })
  map("n", "<leader>gu", function() M.pull() end, { desc = "Pull (rebase, autostash)" })
  map("n", "<leader>gP", M.push, { desc = "Push" })
  map("n", "<leader>gs", function() M.pull(M.push) end, { desc = "Sync (pull, then push)" })
  map("n", "<leader>gf", function()
    last_fetch = 0
    M.refresh()
  end, { desc = "Fetch remote now" })
end

return M
