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

      -- CODE BLOCKS: no fill, thin box (top/bottom borders + show fences as side borders)
      ode = {
        -- Turn on / off code block & inline code rendering.
        enabled = true,
        -- Additional modes to render code blocks.
        render_modes = false,
        -- Turn on / off sign column related rendering.
        sign = true,
        -- Whether to conceal nodes at the top and bottom of code blocks.
        conceal_delimiters = true,
        -- Turn on / off language heading related rendering.
        language = true,
        -- Determines where language icon is rendered.
        -- | right | right side of code block |
        -- | left  | left side of code block  |
        position = "left",
        -- Whether to include the language icon above code blocks.
        language_icon = true,
        -- Whether to include the language name above code blocks.
        language_name = true,
        -- Whether to include the language info above code blocks.
        language_info = true,
        -- Amount of padding to add around the language.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        language_pad = 0,
        -- A list of language names for which background highlighting will be disabled.
        -- Likely because that language has background highlights itself.
        -- Use a boolean to make behavior apply to all languages.
        -- Borders above & below blocks will continue to be rendered.
        disable_background = { "diff" },
        -- Width of the code block background.
        -- | block | width of the code block  |
        -- | full  | full width of the window |
        width = "full",
        -- Amount of margin to add to the left of code blocks.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        -- Margin available space is computed after accounting for padding.
        left_margin = 0,
        -- Amount of padding to add to the left of code blocks.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        left_pad = 0,
        -- Amount of padding to add to the right of code blocks when width is 'block'.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        right_pad = 0,
        -- Minimum width to use for code blocks when width is 'block'.
        min_width = 0,
        -- Determines how the top / bottom of code block are rendered.
        -- | none  | do not render a border                               |
        -- | thick | use the same highlight as the code body              |
        -- | thin  | when lines are empty overlay the above & below icons |
        -- | hide  | conceal lines unless language name or icon is added  |
        border = "hide",
        -- Used above code blocks to fill remaining space around language.
        language_border = "█",
        -- Added to the left of language.
        language_left = "",
        -- Added to the right of language.
        language_right = "",
        -- Used above code blocks for thin border.
        above = "▄",
        -- Used below code blocks for thin border.
        below = "▀",
        -- Turn on / off inline code related rendering.
        inline = true,
        -- Icon to add to the left of inline code.
        inline_left = "",
        -- Icon to add to the right of inline code.
        inline_right = "",
        -- Padding to add to the left & right of inline code.
        inline_pad = 0,
        -- Highlight for code blocks.
        highlight = "RenderMarkdownCode",
        -- Highlight for code info section, after the language.
        highlight_info = "RenderMarkdownCodeInfo",
        -- Highlight for language, overrides icon provider value.
        highlight_language = nil,
        -- Highlight for border, use false to add no highlight.
        highlight_border = "RenderMarkdownCodeBorder",
        -- Highlight for language, used if icon provider does not have a value.
        highlight_fallback = "RenderMarkdownCodeFallback",
        -- Highlight for inline code.
        highlight_inline = "RenderMarkdownCodeInline",
        -- Determines how code blocks & inline code are rendered.
        -- | none     | { enabled = false }                           |
        -- | normal   | { language = false }                          |
        -- | language | { disable_background = true, inline = false } |
        -- | full     | uses all default values                       |
        style = "full",
      },
      -- HEADING: single coloured underline, no background fill
      heading = {
        enabled = true,
        render_modes = false,
        atx = true,
        setext = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        position = "overlay",
        signs = { "󰫎 " },

        width = "block",
        border = true,
        border_virtual = false,
        border_prefix = false,
        above = "",
        below = "─",
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

      -- … other sections unchanged …
    },

    config = function(_, opts)
      require("render-markdown").setup(opts)

      -- toggle key
      vim.keymap.set(
        "n",
        "<Leader>ppp",
        "<Cmd>RenderMarkdown toggle<CR>",
        { silent = true, desc = "Toggle Render Markdown" }
      )

      -- coloured heading underlines
      local blues = {
        { fg = "#BFE2FF" }, -- H1
        { fg = "#93C5FD" }, -- H2
        { fg = "#60A5FA" }, -- H3
        { fg = "#3B82F6" }, -- H4
        { fg = "#2563EB" }, -- H5
        { fg = "#164E8C" }, -- H6
      }
      for i, col in ipairs(blues) do
        vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i, { fg = col.fg, bold = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", { fg = col.fg })
      end

      -- remove any code background fill
      vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "none" })
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeInfo", { bg = "none" })

      -- code border colour (matches your theme or adjust as you like)
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeBorder", { fg = "#888888", bg = "none" })

      -- quote colours
      local oranges = {
        "#FFA500",
        "#FF8C00",
        "#FF7F50",
        "#FF6347",
        "#FF4500",
        "#FF3300",
      }
      for i, color in ipairs(oranges) do
        vim.api.nvim_set_hl(0, "RenderMarkdownQuote" .. i, { fg = color, italic = true })
      end
    end,
  },
}
