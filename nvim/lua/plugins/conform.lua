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
        desc = "Format buffer",
      },
    },

    config = function()
      local conform = require("conform")
      local cwd = vim.loop.cwd
      local fs_find = vim.fs.find
      local expand = vim.fn.expand
      local fs_stat = vim.loop.fs_stat

      local fallback_root = expand("~/.config/formatters")

      local function has_project_file(names)
        return #fs_find(names, { upward = true, path = cwd(), type = "file" }) > 0
      end

      local function exists(path)
        return fs_stat(path) ~= nil
      end

      local function first_existing(paths)
        for _, p in ipairs(paths) do
          if exists(p) then
            return p
          end
        end
        return nil
      end

      -- Common Prettier config filenames to search for
      local PRETTIER_CONFIG_NAMES = {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.json5",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        ".prettierrc.toml",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
      }

      -- Try to locate prettier-plugin-svelte (project first, then fallback dir)
      local function find_prettier_plugin_svelte()
        local hit = vim.fs.find("node_modules/prettier-plugin-svelte", {
          upward = true,
          path = cwd(),
          type = "directory",
        })
        if #hit > 0 then
          return hit[1]
        end
        local fb = fallback_root .. "/node_modules/prettier-plugin-svelte"
        if exists(fb) then
          return fb
        end
        return nil
      end

      -- Stylua with explicit defaults (independent of local config)
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

      -- clang-format with project .clang-format or fallback, else defaults
      local function clang_fmt(bufnr)
        local file = vim.api.nvim_buf_get_name(bufnr)
        local style_arg = has_project_file({ ".clang-format", "_clang-format" }) and "--style=file"
          or "--style=file:" .. fallback_root .. "/.clang-format"
        return {
          command = "clang-format",
          args = { style_arg, "--assume-filename", file, "-" },
          stdin = true,
        }
      end

      -- rustfmt (let rustfmt pick up rustfmt.toml if present)
      local rustfmt_fmt = {
        command = "rustfmt",
        args = { "--emit", "stdout" },
        stdin = true,
      }

      -- black with project pyproject.toml or fallback, else defaults
      local function black_fmt(bufnr)
        local file = vim.api.nvim_buf_get_name(bufnr)
        local args = { "--quiet", "--fast", "--stdin-filename", file, "-" }
        if not has_project_file({ "pyproject.toml" }) then
          local fb = fallback_root .. "/pyproject.toml"
          if exists(fb) then
            table.insert(args, 1, "--config=" .. fb)
          end
        end
        return { command = "black", args = args, stdin = true }
      end

      -- Prettier with three-level fallback:
      -- 1) project config, 2) ~/.config/formatters/*, 3) Prettier defaults
      -- Also wires in prettier-plugin-svelte for .svelte files when found.
      local function prettier_fmt(bufnr)
        local file = vim.api.nvim_buf_get_name(bufnr)
        local args = { "--stdin-filepath", file }

        if not has_project_file(PRETTIER_CONFIG_NAMES) then
          local fallback_candidates = {}
          for _, name in ipairs(PRETTIER_CONFIG_NAMES) do
            table.insert(fallback_candidates, fallback_root .. "/" .. name)
          end
          local fallback_cfg = first_existing(fallback_candidates)
          if fallback_cfg then
            table.insert(args, 1, fallback_cfg)
            table.insert(args, 1, "--config")
          end
          -- If neither project nor fallback config exists, run with defaults
        end

        if file:match("%.svelte$") then
          local plugin = find_prettier_plugin_svelte()
          if plugin then
            -- Help Prettier discover the plugin regardless of current working dir
            table.insert(args, 1, plugin)
            table.insert(args, 1, "--plugin")
            table.insert(args, 1, cwd())
            table.insert(args, 1, "--plugin-search-dir")
          end
        end

        return { command = "prettier", args = args, stdin = true }
      end

      conform.setup({
        debug = true,
        notify_on_error = false,

        format_on_save = false,
        stop_after_first = true,

        formatters = {
          stylua = stylua,
          clang_format = clang_fmt,
          black = black_fmt,
          prettier = prettier_fmt,
          rustfmt = rustfmt_fmt,
        },

        formatters_by_ft = {
          -- Lua / Python / Shell / C-family / Rust
          lua = { "stylua" },
          python = { "black" },
          sh = { "shfmt" },
          c = { "clang_format" },
          cpp = { "clang_format" },
          rust = { "rustfmt" },

          -- Markdown
          markdown = { "prettier" },
          md = { "prettier" },

          -- Web stack
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          less = { "prettier" },

          -- Svelte
          svelte = { "prettier" },
        },
      })
    end,
  },
}

