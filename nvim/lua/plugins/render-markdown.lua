-- lua/plugins/render_markdown.lua
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "md", "mkd", "markdown.mdx" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.nvim",
    },
    opts = {
      enabled = true,
      render_modes = { "n", "c", "t" },
      max_file_size = 10.0,
      debounce = 100,
      preset = "none",
      log_level = "error",
      log_runtime = false,
      file_types = { "markdown" },
      ignore = function()
        return false
      end,
      change_events = {},
      injections = {
        gitcommit = {
          enabled = true,
          query = [[
            ((message) @injection.content
                (#set! injection.combined)
                (#set! injection.include-children)
                (#set! injection.language "markdown"))
          ]],
        },
      },
      patterns = {
        markdown = {
          disable = true,
          directives = {
            { id = 17, name = "conceal_lines" },
            { id = 18, name = "conceal_lines" },
          },
        },
      },
      anti_conceal = {
        enabled = true,
        ignore = { code_background = true, sign = true },
        above = 0,
        below = 0,
      },
      padding = { highlight = "Normal" },
      latex = {
        enabled = true,
        render_modes = false,
        converter = "latex2text",
        highlight = "RenderMarkdownMath",
        position = "above",
        top_pad = 0,
        bottom_pad = 0,
      },
      on = {
        attach = function() end,
        initial = function() end,
        render = function() end,
        clear = function() end,
      },
      completions = {
        blink = { enabled = false },
        coq = { enabled = false },
        lsp = { enabled = false },
        filter = {
          callout = function()
            return true
          end,
          checkbox = function()
            return true
          end,
        },
      },
      heading = {
        enabled = true,
        render_modes = false,
        atx = true,
        setext = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        position = "overlay",
        signs = { "󰫎 " },
        width = "full",
        left_margin = 0,
        left_pad = 0,
        right_pad = 0,
        min_width = 0,
        border = false,
        border_virtual = false,
        border_prefix = false,
        above = "▄",
        below = "▀",
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
        custom = {},
      },
      -- ... other sections unchanged ...
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.keymap.set(
        "n",
        "<Leader>m",
        "<Cmd>RenderMarkdown toggle<CR>",
        { silent = true, desc = "Toggle Render Markdown" }
      )

      local blues = {
        { fg = "#BFE2FF", bg = "#5077C1" }, -- H1: Lightest blue on mid-dark
        { fg = "#93C5FD", bg = "#405F9B" }, -- H2
        { fg = "#60A5FA", bg = "#304679" }, -- H3
        { fg = "#3B82F6", bg = "#203156" }, -- H4
        { fg = "#2563EB", bg = "#10203D" }, -- H5
        { fg = "#164E8C", bg = "#090F21" }, -- H6: Darkest blue on near-black
      }
      for i, col in ipairs(blues) do
        vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i, { fg = col.fg, bold = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", { bg = col.bg })
      end
    end,
  },
}
