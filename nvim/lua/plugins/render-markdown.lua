
-- lua/plugins/render_markdown.lua
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'md', 'mkd', 'markdown.mdx' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.nvim',           -- for icons (or swap for mini.icons / nvim-web-devicons)
    },
    opts = {
      -- which filetypes to auto-render in
      file_types   = { 'markdown', 'vimwiki' },

      -- how many lines above/below cursor to keep un-concealed
      anti_conceal = { enabled = true, buffer_threshold = 200, min_width = 40 },

      -- icons & padding for headings, lists, etc.
      bullets = {
        -- normal list bullets
        list = {
          icon      = '•',
          padding   = 1,
          conceal   = true,
        },
        -- checkboxes
        checkbox = {
          icons = {
            checked   = { icon = '', hl = 'RenderMarkdownChecked' },
            unchecked = { icon = '', hl = 'RenderMarkdownUnchecked' },
            indeterminate = { icon = '', hl = 'RenderMarkdownTodo' },
          },
          padding = 1,
          conceal = true,
        },
      },

      -- code block styling
      code_blocks = {
        style = 'fancy',      -- "fancy" draws a border; "minimal" just padding
        padding = 1,
        width   = 'auto',     -- 'auto' fills editor, or number of cols
      },

      -- fenced latex/math blocks
      latex = {
        enabled = true,       -- requires pylatexenc + treesitter parser
        wrap     = 'inline',  -- 'inline' or 'block'
      },

      -- tables: auto-align, draw borders
      tables = {
        enabled      = true,
        auto_align   = true,
        border_style = 'unicode',  -- ascii|unicode
      },

      -- callouts (admonitions)
      callouts = {
        icons = {
          info    = '',
          warning = '',
          error   = '',
          success = '',
        },
        padding = 1,
      },

      -- whether to render horizontal rules, images, links, etc.
      render = {
        horizontal_rules = { icon = '―', color = 'RenderMarkdownDash' },
        links = { icon = '🔗', color = 'RenderMarkdownLink' },
        images = { only_at_cursor = true },
      },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)
      -- toggle with <Leader>m in markdown files
      vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>m', '<Cmd>RenderMarkdown toggle<CR>',
        { silent = true, desc = 'Toggle Render Markdown' })
    end,
  },
}
