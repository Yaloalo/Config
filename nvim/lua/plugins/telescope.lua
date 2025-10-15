return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local themes = require("telescope.themes")
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      local layout_actions = require("telescope.actions.layout")
      local action_state = require("telescope.actions.state")
      local Path = require("plenary.path")
      local tconfig = require("telescope.config")
      local notify = vim.notify

      -- ─── STATE & LAST‐RUN TRACKING ────────────────────────────────
      local respect_gitignore = true
      local last_picker_fn = nil

      -- ─── GLOBAL <C-h> ─ toggle ignore & rerun last picker ────────
      vim.keymap.set("n", "<C-f>", function()
        respect_gitignore = not respect_gitignore
        notify(
          "Telescope ▶ "
            .. (respect_gitignore and "now respecting .gitignore" or "now ignoring .gitignore")
        )
        if last_picker_fn then
          last_picker_fn()
        end
      end, { desc = "Toggle .gitignore respect & rerun last picker" })

      -- ─── BASE OPTIONS ────────────────────────────────────────────
      local base_find_opts = { hidden = true, path_display = { "absolute" } }

      local function apply_ignore_opts(opts)
        if not respect_gitignore then
          opts.find_command =
            { "fd", "--type", "file", "--color", "never", "--hidden", "--no-ignore-vcs" }
        else
          opts.find_command = { "fd", "--type", "file", "--color", "never", "--hidden" }
        end
        return opts
      end

      -- ─── WRAPPERS THAT TRACK THEMSELVES ──────────────────────────
      local function launch_find()
        local opts = vim.tbl_deep_extend("force", {}, base_find_opts)
        opts = apply_ignore_opts(opts)
        last_picker_fn = launch_find
        builtin.find_files(opts)
      end

      local function launch_live_grep()
        local args = vim.tbl_flatten({
          tconfig.values.vimgrep_arguments,
          (respect_gitignore and {} or { "--no-ignore-vcs" }),
        })
        last_picker_fn = launch_live_grep
        builtin.live_grep({ vimgrep_arguments = args })
      end

      local function launch_grep_string()
        local word = vim.fn.expand("<cword>")
        local args = vim.tbl_flatten({
          tconfig.values.vimgrep_arguments,
          (respect_gitignore and {} or { "--no-ignore-vcs" }),
        })
        last_picker_fn = launch_grep_string
        builtin.grep_string({ search = word, vimgrep_arguments = args })
      end

      local function launch_file_browser()
        last_picker_fn = launch_file_browser
        telescope.extensions.file_browser.file_browser({})
      end

      local function launch_git_commits()
        last_picker_fn = launch_git_commits
        builtin.git_commits({
          attach_mappings = function(_, map)
            local function open_commit(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.cmd("vnew | setlocal buftype=nofile bufhidden=wipe swapfile=false")
              vim.api.nvim_buf_set_lines(
                0,
                0,
                -1,
                false,
                vim.fn.systemlist("git show " .. entry.value)
              )
              vim.cmd("setfiletype diff")
            end
            map("i", "<C-s>", open_commit)
            map("n", "<C-s>", open_commit)
            return true
          end,
        })
      end

      -- ─── TELESCOPE SETUP ───────────────────────────────────────────
      telescope.setup({
        defaults = {
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
          file_ignore_patterns = {},
          mappings = {
            i = {
              ["<C-c>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-o>"] = function(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                if entry then
                  actions.close(prompt_bufnr)
                  local target = entry.path or entry.value
                  local dir = Path:new(target):is_dir() and target
                    or vim.fn.fnamemodify(target, ":h")
                  vim.cmd("Oil " .. vim.fn.fnameescape(dir))
                end
              end,
              ["<C-f>"] = function(prompt_bufnr)
                respect_gitignore = not respect_gitignore
                notify(
                  "Telescope ▶ "
                    .. (
                      respect_gitignore and "now respecting .gitignore" or "now ignoring .gitignore"
                    )
                )
                actions.close(prompt_bufnr)
                vim.schedule(function()
                  if last_picker_fn then
                    last_picker_fn()
                  end
                end)
              end,
              ["<C-g>"] = layout_actions.toggle_preview,
            },
            n = {
              ["q"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-o>"] = function(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                if entry then
                  actions.close(prompt_bufnr)
                  local target = entry.path or entry.value
                  local dir = Path:new(target):is_dir() and target
                    or vim.fn.fnamemodify(target, ":h")
                  vim.cmd("Oil " .. vim.fn.fnameescape(dir))
                end
              end,
              ["<C-f>"] = function(prompt_bufnr)
                respect_gitignore = not respect_gitignore
                notify(
                  "Telescope ▶ "
                    .. (
                      respect_gitignore and "now respecting .gitignore" or "now ignoring .gitignore"
                    )
                )
                actions.close(prompt_bufnr)
                vim.schedule(function()
                  if last_picker_fn then
                    last_picker_fn()
                  end
                end)
              end,
              ["<C-g>"] = layout_actions.toggle_preview,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
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

      telescope.load_extension("ui-select")
      telescope.load_extension("file_browser")

      -- ─── SEARCH KEYMAPS ───────────────────────────────────────────
      vim.keymap.set("n", "<leader>sf", launch_find, { desc = "󰝰 Find Files" })
      vim.keymap.set("n", "<leader>sg", launch_live_grep, { desc = " Live Grep" })
      vim.keymap.set("n", "<leader>ss", launch_grep_string, { desc = " Grep String" })
      vim.keymap.set("n", "<leader>sb", launch_file_browser, { desc = " File Browser" })
      vim.keymap.set("n", "<leader>sc", launch_git_commits, { desc = " Git Commits" })

      -- ─── Standalone Search Neovim Config ──────────────────────────────────
      vim.keymap.set("n", "<leader>sn", function()
        require("telescope.builtin").find_files({
          cwd = vim.fn.stdpath("config"),
          hidden = true,
          -- unconditionally include hidden, ignore gitignore toggle
          find_command = { "fd", "--type", "file", "--color", "never", "--hidden" },
        })
      end, { desc = " Search Neovim Config" })
    end,
  },
}
