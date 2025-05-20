return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local themes = require("telescope.themes")
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },
          prompt_prefix = "🔍 ",
          selection_caret = "➤ ",
          entry_prefix = "  ",
          initial_mode = "insert",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { preview_width = 0.6 },
            vertical = { preview_height = 0.5 },
            width = 0.9,
            height = 0.8,
            preview_cutoff = 120,
          },
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          file_ignore_patterns = { "node_modules", ".git/" },
          mappings = {
            i = {
              ["<C-c>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
            n = {
              ["q"] = actions.close,
              ["<CR>"] = actions.select_default,
            },
          },
        },
        pickers = {
          find_files = { hidden = true, no_ignore = true },
          live_grep = { only_sort_text = true },
        },
        extensions = {
          ["ui-select"] = themes.get_dropdown({}),
          file_browser = {
            hidden = true,
            hijack_netrw = true,
            cwd_to_path = true,
            layout_strategy = "horizontal",
            layout_config = {
              horizontal = { preview_width = 0.6 },
              width = 0.9,
              height = 0.8,
              preview_cutoff = 120,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("file_browser")

      -- standard search mappings
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "  Find Files" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "  Live Grep" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "  Telescope" })
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "  Help Tags" })
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({
          cwd = vim.fn.stdpath("config"),
          prompt_title = "~ Config ~",
        })
      end, { desc = "  Search Neovim Config" })
      vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "﬘  Open Buffers" })
      vim.keymap.set("n", "<leader>so", builtin.oldfiles, { desc = "  Recent Files" })

      -- file-browser at cwd
      vim.keymap.set("n", "<leader>sr", function()
        require("telescope").extensions.file_browser.file_browser({
          path = vim.fn.getcwd(),
          cwd = vim.fn.getcwd(),
          select_buffer = true,
          hidden = true,
          hijack_netrw = true,
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { preview_width = 0.6 },
            width = 0.9,
            height = 0.8,
            preview_cutoff = 120,
          },
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          attach_mappings = function(prompt_bufnr, map)
            map("n", "<CR>", function()
              local sel = action_state.get_selected_entry()
              if not sel then
                return
              end
              local p = sel.path or sel.value
              actions.close(prompt_bufnr)
              if vim.fn.isdirectory(p) == 1 then
                vim.api.nvim_set_current_dir(p)
                print("  Changed cwd to " .. p)
              else
                vim.cmd("edit " .. p)
              end
            end)
            return true
          end,
        })
      end, { desc = "󰉓 Telescope File Browser (cwd)" })

      -- search whole disk for directories (uses root '/'), mapping <leader>sw
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = "<Up>",
          Down = "<Down>",
          Left = "<Left>",
          Right = "<Right>",
          C = "<C-…>",
          M = "<M-…>",
          D = "<D-…>",
          S = "<S-…>",
          CR = "<CR>",
          Esc = "<Esc>",
          Space = "<Space>",
          Tab = "<Tab>",
        },
      },
      spec = {
        { "<leader>s", group = "[S]earch" },
        { "<leader>g", group = "[G]it" },
        -- removed <leader>w mapping
      },
    },
  },
}
