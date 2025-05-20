-- ~/.config/nvim/lua/plugins/ui.lua
return {
	-- Tokyo Night theme
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = {
			style = "night", -- choices: storm, night, day
			transparent = false,
			terminal_colors = true,
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- Alpha dashboard
	{
		"goolord/alpha-nvim",
		dependencies = { "echasnovski/mini.icons", "nvim-lua/plenary.nvim" },
		config = function()
			require("alpha").setup(require("alpha.themes.theta").config)
		end,
	},

	-- Lualine Statusline
	-- Lualine Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup {
				options           = {
					icons_enabled        = true,
					theme                = "auto",
					-- round-style separators:
					component_separators = { left = "", right = "" },
					section_separators   = { left = "", right = "" },
					disabled_filetypes   = { statusline = {}, winbar = {} },
					ignore_focus         = {},
					always_divide_middle = true,
					always_show_tabline  = true,
					globalstatus         = false,
					refresh              = { statusline = 100, tabline = 100, winbar = 100 },
				},
				sections          = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "fileformat", "filetype" },
					-- removed the AutoFmt component here:
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline           = {},
				winbar            = {},
				inactive_winbar   = {},
				extensions        = {},
			}
		end,
	},

	-- TODO comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- Mini suite
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup { n_lines = 500 }
			require("mini.surround").setup()
			require("mini.statusline").setup { use_icons = vim.g.have_nerd_font }
		end,
	},
}
