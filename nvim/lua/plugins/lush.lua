-- lua/plugins/lush.lua
return {
  {
    "rktjmp/lush.nvim",
    priority = 1000,
    lazy     = false,
    config   = function()
      -- True-colour event-horizon theme.
      vim.o.termguicolors = true
      vim.opt.background   = "dark"

      -- 2) Import Lush + HSL helper
      local lush = require("lush")
      local hsl  = lush.hsl
      local palette = require("core.palette")

      -- 3) Palette
      local colors = {
        bg        = hsl(palette.void),
        bg_alt    = hsl(palette.surface),
        fg        = hsl(palette.text),
        constant  = hsl(palette.cobalt),
        string    = hsl(palette.ice),
        func      = hsl(palette.blue),
        global    = hsl(palette.text),
        comment   = hsl(palette.muted),
        linenr    = hsl(palette.outline),
        type      = hsl(palette.cobalt),
      }

      -- Flag for transparency
      local transparent_enabled = true

      -- 4) Function to (re)build and apply the Lush spec
      local function apply_theme()
        local theme = lush(function()
          -- If transparent: all bg that used to be bg/bg_alt become "NONE"
          local bg     = transparent_enabled and "NONE" or colors.bg
          local bg_alt = transparent_enabled and "NONE" or colors.bg_alt

          return {
            -- Base UI groups
            Normal        { fg = colors.fg,       bg = bg      },
            NormalFloat   { fg = colors.fg,       bg = bg      },
            CursorLine    {                      bg = bg_alt   },
            CursorColumn  {                      bg = bg       },
            LineNr        { fg = colors.linenr,  bg = bg       },
            CursorLineNr  { fg = colors.constant, bg = bg_alt  },
            VertSplit     { fg = colors.fg,       bg = bg      },

            -- Core syntax
            Constant      { fg = colors.constant, bg = "NONE"  },
            String        { fg = colors.string,   bg = "NONE"  },
            Comment       { fg = colors.comment,  bg = bg, gui = "italic" },
            Function      { fg = colors.func,     bg = "NONE"  },
            Type          { fg = colors.type,     bg = "NONE"  },

            -- Other syntax
            Keyword       { fg = colors.fg },
            Statement     { fg = colors.fg },
            PreProc       { fg = colors.fg },
            Special       { fg = colors.fg },
            Identifier    { fg = colors.fg },
            Underlined    { fg = colors.fg },
            Todo          { fg = colors.fg,       bg = bg      },

            -- Diagnostics
            Error         { fg = colors.constant, bg = bg, gui = "bold" },
            Warning       { fg = colors.global,   bg = bg      },
            Info          { fg = colors.string,   bg = bg      },
            Hint          { fg = colors.comment,  bg = bg      },

            -- Treesitter groups
            TSKeyword         { fg = colors.fg },
            TSKeywordFunction { fg = colors.fg },
            TSVariable        { fg = colors.fg },
            TSField           { fg = colors.fg },
            TSProperty        { fg = colors.fg },
            TSMethod          { fg = colors.fg },
            TSFunction        { fg = colors.func   },
            TSConstant        { fg = colors.constant },
            TSString          { fg = colors.string   },
            TSComment         { fg = colors.comment, bg = bg, gui = "italic" },
            TSParameter       { fg = colors.fg },
            TSConstructor     { fg = colors.fg },
            TSConditional     { fg = colors.fg },
            TSRepeat          { fg = colors.fg },
            TSOperator        { fg = colors.fg },
            TSException       { fg = colors.fg },
            TSLabel           { fg = colors.fg },
            TSInclude         { fg = colors.fg },
            TSStructure       { fg = colors.type    },

            -- Lualine & Winbar
            StatusLine        { fg = colors.fg,    bg = bg },
            StatusLineNC      { fg = colors.fg,    bg = bg },
            TabLineFill       { fg = colors.fg,    bg = bg },
            TabLineSel        { fg = colors.fg,    bg = bg },
            TabLine           { fg = colors.fg,    bg = bg },
            WinBar            { fg = colors.fg,    bg = bg },
            WinBarNC          { fg = colors.fg,    bg = bg },
            SagaWinbar        { fg = colors.fg,    bg = bg },
            SagaWinbarSep     { fg = colors.comment, bg = bg },

            -- Floats & Borders
            FloatBorder       { fg = colors.fg,    bg = bg },

            -- Telescope
            TelescopeBorder        { fg = colors.string, bg = bg },
            TelescopePromptBorder  { fg = colors.string, bg = bg },
            TelescopeResultsBorder { fg = colors.string, bg = bg },
            TelescopePreviewBorder { fg = colors.string, bg = bg },

            -- Floaterm
            FloatermBorder       { fg = colors.string, bg = bg },
          }
        end)

        lush(theme)
      end

      -- Apply theme initially (opaque by default, like before)
      apply_theme()

      -- 5) Keymap: toggle transparency with Ctrl+b
      local function toggle_transparency()
        transparent_enabled = not transparent_enabled
        apply_theme()
      end
      vim.keymap.set("n", "<C-b>", toggle_transparency, { desc = "Toggle background transparency (lush theme)" })
      vim.keymap.set("n", "<leader>uo", toggle_transparency, { desc = "Toggle background transparency (lush theme)" })
    end,
  },
}
