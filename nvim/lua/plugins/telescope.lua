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
      local telescope      = require("telescope")
      local themes         = require("telescope.themes")
      local builtin        = require("telescope.builtin")
      local actions        = require("telescope.actions")
      local action_state   = require("telescope.actions.state")
      local Path           = require("plenary.path")

      ---------------------------------------------------------------------------------------------------
      -- 1) GLOBAL “RESPECT .GITIGNORE” TOGGLE
      ---------------------------------------------------------------------------------------------------
      local respect_gitignore = true
      local function toggle_gitignore()
        respect_gitignore = not respect_gitignore
        if respect_gitignore then
          vim.notify(".gitignore → now respected", vim.log.levels.INFO)
        else
          vim.notify(".gitignore → now ignored", vim.log.levels.INFO)
        end
      end
      vim.keymap.set("n", "<C-g>", toggle_gitignore, { desc = "🔃 Toggle .gitignore in Telescope" })

      ---------------------------------------------------------------------------------------------------
      -- 2) CUSTOM FIND FILES FUNCTION (no <All> in title)
      ---------------------------------------------------------------------------------------------------
      local custom_find_files
      custom_find_files = function(opts, no_ignore)
        opts = opts or {}
        no_ignore = vim.F.if_nil(no_ignore, false)
        opts.attach_mappings = function(_, map)
          map({ "n", "i" }, "<C-h>", function(prompt_bufnr)
            local prompt = action_state.get_current_line()
            actions.close(prompt_bufnr)
            no_ignore = not no_ignore
            custom_find_files({ default_text = prompt }, no_ignore)
          end)
          return true
        end

        if no_ignore then
          opts.no_ignore = true
          opts.hidden = true
        end

        require("telescope.builtin").find_files(opts)
      end

      ---------------------------------------------------------------------------------------------------
      -- 3) DIRECTORY SELECTOR / SCOPED SEARCH
      ---------------------------------------------------------------------------------------------------
      local chosen_dir = nil

      local function choose_directory()
        local find_cmd = { "fd", "--type", "d", "--hidden", "--follow" }
        if respect_gitignore then
          table.insert(find_cmd, "--exclude")
          table.insert(find_cmd, ".git")
        else
          table.insert(find_cmd, "--no-ignore")
        end

        require("telescope.builtin").find_files({
          prompt_title  = "Choose Directory",
          cwd           = vim.fn.getcwd(),
          find_command  = find_cmd,
          attach_mappings = function(prompt_bufnr, map)
            map("i", "<CR>", function()
              local selection = action_state.get_selected_entry()
              if selection then
                chosen_dir = selection.path or selection.value
                print("󰉋  Selected directory: " .. chosen_dir)
              else
                print("⚠️  No directory selected")
              end
              actions.close(prompt_bufnr)
            end)
            map("n", "<CR>", function()
              local selection = action_state.get_selected_entry()
              if selection then
                chosen_dir = selection.path or selection.value
                print("󰉋  Selected directory: " .. chosen_dir)
              else
                print("⚠️  No directory selected")
              end
              actions.close(prompt_bufnr)
            end)
            return true
          end,
        })
      end

      local function search_in_chosen_directory()
        if not chosen_dir then
          print("⚠️  No directory selected yet! Use <leader>sd first.")
          return
        end

        require("telescope.builtin").find_files({
          prompt_title = "Find in Chosen Dir",
          cwd          = chosen_dir,
          hidden       = true,
          no_ignore    = not respect_gitignore,
        })
      end

      ---------------------------------------------------------------------------------------------------
      -- 4) TELESCOPE SETUP: <C-o> mapping for Oil
      ---------------------------------------------------------------------------------------------------
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
              ["<C-o>"] = function(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                if not entry then return end
                local selected_path = entry.path or entry.value
                actions.close(prompt_bufnr)
                local target_dir = Path:new(selected_path):is_dir()
                  and selected_path
                  or vim.fn.fnamemodify(selected_path, ":h")
                vim.cmd("Oil " .. vim.fn.fnameescape(target_dir))
              end,
            },
            n = {
              ["q"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-o>"] = function(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                if not entry then return end
                local selected_path = entry.path or entry.value
                actions.close(prompt_bufnr)
                local target_dir = Path:new(selected_path):is_dir()
                  and selected_path
                  or vim.fn.fnamemodify(selected_path, ":h")
                vim.cmd("Oil " .. vim.fn.fnameescape(target_dir))
              end,
            },
          },
        },
        pickers = {
          find_files = { hidden = true, no_ignore = true },
          live_grep  = { only_sort_text = true },
        },
        extensions = {
          ["ui-select"] = themes.get_dropdown({}),
          file_browser = {
            hidden            = true,
            hijack_netrw      = true,
            cwd_to_path       = true,
            respect_gitignore = respect_gitignore,
            layout_strategy   = "horizontal",
            layout_config     = {
              horizontal = { preview_width = 0.6 },
              width      = 0.9,
              height     = 0.8,
              preview_cutoff = 120,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("file_browser")

      -- 🔸 BORDER COLOR OVERRIDES
      local border_color = "#005FBB"
      for _, group in ipairs({
        "TelescopeBorder",
        "TelescopePromptBorder",
        "TelescopeResultsBorder",
        "TelescopePreviewBorder",
      }) do
        vim.api.nvim_set_hl(0, group, { fg = border_color })
      end
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = border_color })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

      ---------------------------------------------------------------------------------------------------
      -- 5) KEY MAPPINGS: all searches respect the toggle; no <All> titles
      ---------------------------------------------------------------------------------------------------

      -- <leader>sf → custom_find_files
      vim.keymap.set("n", "<leader>sf", function()
        custom_find_files()
      end, { desc = "󰝰 Custom Find Files" })

      -- <leader>sg → live_grep
      vim.keymap.set("n", "<leader>sg", function()
        builtin.live_grep({
          additional_args = function()
            local args = { "--hidden" }
            if not respect_gitignore then
              table.insert(args, "--no-ignore")
            end
            return args
          end,
        })
      end, { desc = "  Live Grep" })

      -- <leader>sn → find_files in config
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({
          cwd       = vim.fn.stdpath("config"),
          hidden    = true,
          no_ignore = not respect_gitignore,
        })
      end, { desc = "  Search Neovim Config" })

      -- <leader>ns → search notes (include folders)
      vim.keymap.set("n", "<leader>ns", function()
        local base_cmd = { "fd", "--type", "f", "--type", "d", "--hidden", "--follow" }
        if not respect_gitignore then
          table.insert(base_cmd, "--no-ignore")
        end
        builtin.find_files({
          cwd          = "/home/yaloalo/notes",
          hidden       = true,
          find_command = base_cmd,
        })
      end, { desc = " Search Notes (include folders)" })


      -- <leader>sd → choose_directory
      vim.keymap.set("n", "<leader>sd", function()
        choose_directory()
      end, { desc = "󰉋 Choose Directory" })

      -- <leader>sx → search_in_chosen_directory
      vim.keymap.set("n", "<leader>sx", function()
        search_in_chosen_directory()
      end, { desc = "󰱿 Search in Chosen Directory" })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      win = {
        no_overlap = true,
        padding = { 1, 2 },
        border = "rounded",
        title = true,
        title_pos = "center",
        zindex = 1000,
        bo = {},
        wo = {
          winblend = 0,
        },
      },
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      layout = {
        width = { min = 20 },
        spacing = 3,
      },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
        mappings = true,
      },
      spec = {
        { "<leader>s", group = "󰈞  [S]earch" },
        { "<leader>d", group = "  [D]ebug" },
        { "<leader>l", group = "  [L]SP" },
        { "<leader>o", group = "󰏆  [O]il" },
        { "<leader>n", group = "󰎞  [N]otes" },
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
      vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "none" })
      vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "none" })
      vim.api.nvim_set_hl(0, "WhichKeyTitle", { bg = "none" })
      vim.api.nvim_set_hl(0, "WinBar", { bg = "none" })
      vim.api.nvim_set_hl(0, "WinBarNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "FloatTitle", { bg = "none" })

      local border_color = "#005FBB"
      vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "none", fg = border_color })
    end,
  },
}
