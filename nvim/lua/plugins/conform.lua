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

      local fallback_root = expand("~/.config/formatters")

      local function has_project_file(names)
        return #fs_find(names, { upward = true, path = cwd(), type = "file" }) > 0
      end

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

      local function clang_fmt(bufnr)
        local file = vim.api.nvim_buf_get_name(bufnr)
        local style_arg = has_project_file({ ".clang-format", "_clang-format" }) and "--style=file"
          or "--style=file:" .. fallback_root .. "/.clang-format"
        return {
          exe = "clang-format",
          args = { style_arg, "--assume-filename", file, "-" },
          stdin = true,
        }
      end

      local function black_fmt(bufnr)
        local file = vim.api.nvim_buf_get_name(bufnr)
        local args = { "--quiet", "--fast", "--stdin-filename", file, "-" }
        if not has_project_file({ "pyproject.toml" }) then
          table.insert(args, 1, "--config=" .. fallback_root .. "/pyproject.toml")
        end
        return { exe = "black", args = args, stdin = true }
      end

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
            args = { "--config", fallback_root .. "/.prettierrc", "--stdin-filepath", file },
            stdin = true,
          }
        end
      end

      conform.setup({
        debug = true,
        notify_on_error = false,

        format_on_save = function()
          return { timeout_ms = 500, lsp_format = "fallback" }
        end,

        stop_after_first = true,

        formatters = {
          stylua = stylua,
          clang_format = clang_fmt,
          black = black_fmt,
          prettier = prettier_fmt,
        },

        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          markdown = { "prettier" },
          sh = { "shfmt" },
          c = { "clang_format" },
          cpp = { "clang_format" },
        },
      })

      vim.api.nvim_create_user_command("W", "noautocmd write", {
        desc = "Save buffer without triggering Conform (or other) BufWritePre",
      })
    end,
  },
}
