-- Desktop theme mode ("star" or "eva"), shared with Quickshell and WezTerm via
-- one plain-text file. The settings toggle rewrites it and runs `hyprctl reload`.
local M = {}

function M.current()
    local state = os.getenv("XDG_STATE_HOME") or ((os.getenv("HOME") or "") .. "/.local/state")
    local file = io.open(state .. "/desktop-mode")
    if not file then return "star" end
    local mode = file:read("*l")
    file:close()
    return mode == "eva" and "eva" or "star"
end

return M
