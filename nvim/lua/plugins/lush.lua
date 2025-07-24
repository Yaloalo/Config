-- lua/plugins/lush.lua
return {
  {
    "rktjmp/lush.nvim",
    priority = 1000,
    lazy     = false,
    config   = function()
      -- 1) True‑color & dark “Storm” background
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
        func      = hsl("#4160fa"), -- new green for functions
        global    = hsl("#ffffff"), -- globals (other than functions)
        comment   = hsl("#565f89"), -- comments and gutter
        linenr    = hsl("#565f89"), -- line numbers
        type      = hsl("#a80f96"), -- purple for types
      }

      -- 4) Build the Lush spec
      local theme = lush(function()
        return {
          -- Base UI groups
          Normal        { fg = colors.fg,      bg = colors.bg        },
          NormalFloat   { fg = colors.fg,      bg = colors.bg        },
          CursorLine    { bg = colors.bg_alt                        },
          CursorColumn  { bg = colors.bg                            },
          LineNr        { fg = colors.linenr,  bg = colors.bg        },
          CursorLineNr  { fg = colors.constant, bg = colors.bg_alt   },
          VertSplit     { fg = colors.fg,      bg = colors.bg        },

          -- Core syntax
          Constant      { fg = colors.constant, bg = "NONE"         },
          String        { fg = colors.string,   bg = "NONE"         },
          Comment       { fg = colors.comment,  bg = colors.bg, gui = "italic" },
          Function      { fg = colors.func,     bg = "NONE"         },
          Type          { fg = colors.type,     bg = "NONE"         },

          -- Other syntax
          Keyword       { fg = colors.fg },
          Statement     { fg = colors.fg },
          PreProc       { fg = colors.fg },
          Special       { fg = colors.fg },
          Identifier    { fg = colors.fg },
          Underlined    { fg = colors.fg },
          Todo          { fg = colors.fg,      bg = colors.bg       },

          -- Diagnostics
          Error         { fg = colors.constant, bg = colors.bg, gui = "bold" },
          Warning       { fg = colors.global,   bg = colors.bg        },
          Info          { fg = colors.string,   bg = colors.bg        },
          Hint          { fg = colors.comment,  bg = colors.bg        },

          -- Treesitter groups
          TSKeyword         { fg = colors.fg },
          TSKeywordFunction { fg = colors.fg },
          TSVariable        { fg = colors.fg },
          TSField           { fg = colors.fg },
          TSProperty        { fg = colors.fg },
          TSMethod          { fg = colors.fg },
          TSFunction        { fg = colors.func   }, -- green for TS functions
          TSConstant        { fg = colors.constant },
          TSString          { fg = colors.string   },
          TSComment         { fg = colors.comment, bg = colors.bg, gui = "italic" },
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
          StatusLine        { fg = colors.fg,    bg = colors.bg },
          StatusLineNC      { fg = colors.fg,    bg = colors.bg },
          TabLineFill       { fg = colors.fg,    bg = colors.bg },
          TabLineSel        { fg = colors.fg,    bg = colors.bg },
          TabLine           { fg = colors.fg,    bg = colors.bg },
          WinBar            { fg = colors.fg,    bg = colors.bg },
          WinBarNC          { fg = colors.fg,    bg = colors.bg },
          SagaWinbar        { fg = colors.fg,    bg = colors.bg },
          SagaWinbarSep     { fg = colors.comment, bg = colors.bg },

          -- Floats & Borders
          FloatBorder       { fg = colors.fg,    bg = colors.bg },

          -- Telescope
          TelescopeBorder        { fg = colors.string, bg = colors.bg },
          TelescopePromptBorder  { fg = colors.string, bg = colors.bg },
          TelescopeResultsBorder { fg = colors.string, bg = colors.bg },
          TelescopePreviewBorder { fg = colors.string, bg = colors.bg },

          FloatermBorder       { fg = colors.string, bg = colors.bg },
        }
      end)

      -- 5) Apply the theme
      lush(theme)
    end,
  },
}

