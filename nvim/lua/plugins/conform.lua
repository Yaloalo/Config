-- ~/.config/nvim/lua/plugins/conform.lua
return {
  {
    "stevearc/conform.nvim",
    debug = true,
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "[F]ormat buffer",
      },
    },

    config = function()
      local conform = require("conform")
      local cwd = vim.loop.cwd
      local fs_find = vim.fs.find
      local expand = vim.fn.expand

      -- Where your *fallback* configs actually live:
      local fallback_root = expand("~/.config/formatters")

      -- Detect any project-local config by searching upward
      local function has_project_file(names)
        return #fs_find(names, { upward = true, path = cwd(), type = "file" }) > 0
      end

      -- Stylua override (unchanged)
      local stylua = {
        inherit = false,
        command = "stylua",
        args = {
          "--config-path",
          "/dev/null",
          "--stdin-filepath",
          "$FILENAME",
          "--indent-type",
          "Spaces",
          "--indent-width",
          "2",
          "--column-width",
          "100",
          "--sort-requires",
          "-",
        },
        stdin = true,
      }

      -- clang-format: project .clang-format? else fallback ~/.config/formatters/.clang-format
      local function clang_fmt(bufnr)
        local file = vim.api.nvim_buf_get_name(bufnr)
        local style_arg
        if has_project_file({ ".clang-format", "_clang-format" }) then
          style_arg = "--style=file"
        else
          style_arg = "--style=file:" .. fallback_root .. "/.clang-format"
        end
        return {
          exe = "clang-format",
          args = { style_arg, "--assume-filename", file, "-" },
          stdin = true,
        }
      end

      -- Black: project pyproject.toml? else fallback ~/.config/formatters/pyproject.toml
      local function black_fmt(bufnr)
        local file = vim.api.nvim_buf_get_name(bufnr)
        local args = { "--quiet", "--fast", "--stdin-filename", file, "-" }
        if not has_project_file({ "pyproject.toml" }) then
          table.insert(args, 1, "--config=" .. fallback_root .. "/pyproject.toml")
        end
        return { exe = "black", args = args, stdin = true }
      end

      -- Prettier: project config? else fallback ~/.config/formatters/.prettierrc
      local function prettier_fmt(bufnr)
        local file = vim.api.nvim_buf_get_name(bufnr)
        local names = {
          ".prettierrc",
          ".prettierrc.json",
          ".prettierrc.js",
          "prettier.config.js",
          ".prettierrc.toml",
        }
        if has_project_file(names) then
          return { exe = "prettier", args = { "--stdin-filepath", file }, stdin = true }
        else
          return {
            exe = "prettier",
            args = {
              "--config",
              fallback_root .. "/.prettierrc",
              "--stdin-filepath",
              file,
            },
            stdin = true,
          }
        end
      end

      -- Final setup — single call
      conform.setup({
        debug = true,
        notify_on_error = false,

        format_on_save = function(bufnr)
          return { timeout_ms = 500, lsp_format = "fallback" }
        end,

        formatters = {
          stylua = stylua,
          clang_format = clang_fmt,
          black = black_fmt,
          prettier = prettier_fmt,
        },

        formatters_by_ft = {
          lua = { "stylua" },
          python = { black_fmt },
          markdown = { prettier_fmt },
          sh = { "shfmt" },
          c = { "clang_format", stop_after_first = true },
          cpp = { "clang_format", stop_after_first = true },
        },
      })

      -- :W to write without auto-format
      vim.api.nvim_create_user_command("W", "noautocmd write", {
        desc = "Save buffer without triggering Conform (or other) BufWritePre",
      })
    end,
  },
}
