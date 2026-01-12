-- lua/plugins/lush.lua
return {
  {
    "rktjmp/lush.nvim",
    priority = 1000,
    lazy     = false,
    config   = function()
      -- 1) True-color & dark “Storm” background
      vim.o.termguicolors = true
      vim.opt.background   = "dark"

      -- 2) Import Lush + HSL helper
      local lush = require("lush")
      local hsl  = lush.hsl

      -- 3) Palette
      local colors = {
        bg        = hsl("#1a1b26"), -- Storm background
        bg_alt    = hsl("#1f2335"), -- darker Storm for CursorLine
        fg        = hsl("#ffffff"), -- default text = white
        constant  = hsl("#FF8700"), -- orange for constants
        string    = hsl("#73daca"), -- turquoise for strings
        func      = hsl("#4160fa"), -- blue for functions
        global    = hsl("#ffffff"), -- globals (other than functions)
        comment   = hsl("#565f89"), -- comments and gutter
        linenr    = hsl("#565f89"), -- line numbers
        type      = hsl("#a80f96"), -- purple for types
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
            TSFunction        { fg = colors.func   }, -- blue for TS functions
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
      -- Note: terminals usually don't distinguish Ctrl+Shift+b, so we just use <C-b>.
      vim.keymap.set("n", "<C-b>", function()
        transparent_enabled = not transparent_enabled
        apply_theme()
      end, { desc = "Toggle background transparency (lush theme)" })
    end,
  },
}

