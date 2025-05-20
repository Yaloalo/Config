-- ~/.config/nvim/lua/plugins/snacks.lua
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy     = false,
	-- snacks.nvim configuration
	opts     = {
		bigfile      = { enabled = true },
		dashboard    = { enabled = false },
		explorer     = { enabled = false },
		indent       = { enabled = false },
		input        = { enabled = true },
		notifier     = { enabled = false, timeout = 3000 },
		picker       = { enabled = false },
		quickfile    = { enabled = true },
		scope        = { enabled = true },
		scroll       = { enabled = false },
		statuscolumn = { enabled = true },
		words        = { enabled = false },
		terminal     = { enabled = true }, -- enable floating terminal
		styles       = {
			notification = {
				-- Wrap notifications if desired
				-- wo = { wrap = true },
			},
		},
	},
	keys     = {

	},
	init     = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- Debug helpers
				_G.dd = function(...) Snacks.debug.inspect(...) end
				_G.bt = function() Snacks.debug.backtrace() end
				vim.print = _G.dd

				-- Example toggle mappings
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
				Snacks.toggle.option("conceallevel", { off = 0, on = 2, name = "Conceal" }):map(
					"<leader>uc")
			end,
		})
	end,
}
