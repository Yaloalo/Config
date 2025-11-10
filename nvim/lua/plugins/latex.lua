-- ~/.config/nvim/lua/plugins/vimtex.lua
return {
  {
    "lervag/vimtex",
    lazy = false, -- load as filetype plugin
    init = function()
      -- Compiler: latexmk; PDF next to .tex
      vim.g.vimtex_compiler_latexmk = {
        options = { "-verbose", "-file-line-error", "-synctex=1", "-interaction=nonstopmode" },
      }

      -- Viewer: Firefox via general (works reliably)
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer  = "firefox"
      vim.g.vimtex_view_general_options = "file://@pdf" -- do NOT quote; avoids http://'path'

      vim.g.vimtex_view_use_temp_files = 0
      vim.g.vimtex_quickfix_open_on_warning = 0 -- only errors pop quickfix
      vim.g.vimtex_mappings_enabled = 0         -- we define our own
      vim.g.tex_flavor = "latex"
    end,

    config = function()
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
      end

      -- Compile / control
      map("<leader>xc", "<Cmd>VimtexCompile<CR>",    "LaTeX: compile (continuous)")
      map("<leader>xs", "<Cmd>VimtexCompileSS<CR>",  "LaTeX: compile (single-shot)")
      map("<leader>xx", "<Cmd>VimtexStop<CR>",       "LaTeX: stop compiler")
      map("<leader>xC", "<Cmd>VimtexClean<CR>",      "LaTeX: clean aux files")

      -- View (Firefox)
      map("<leader>xo", "<Cmd>VimtexView<CR>",       "LaTeX: open/view PDF")

      -- Inspect / tools
      map("<leader>xq", "<Cmd>VimtexErrors<CR>",     "LaTeX: errors (quickfix)")
      map("<leader>xi", "<Cmd>VimtexInfo<CR>",       "LaTeX: info")
      map("<leader>xt", "<Cmd>VimtexTocOpen<CR>",    "LaTeX: table of contents")
      map("<leader>xl", "<Cmd>VimtexLog<CR>",        "LaTeX: log")
      map("<leader>xL", "<Cmd>VimtexLabelsOpen<CR>", "LaTeX: labels/citations")

      -- Debug opener (prints and runs exact command)
      map("<leader>xO", function()
        local pdf  = vim.fn.expand("%:p:r") .. ".pdf"
        local cmd  = string.format([[firefox "file://%s" &]], pdf)
        print(cmd)
        vim.fn.system({ "sh", "-c", cmd })
      end, "LaTeX: open in Firefox (debug)")
    end,
  },
}

