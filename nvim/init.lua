vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Must run before any mapping is defined so the keybinding menu (<leader>?)
-- knows where each mapping came from.
require("core.keymenu").track()

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.markdown")
require("core.git_sync").setup()
require("core.plugins")
