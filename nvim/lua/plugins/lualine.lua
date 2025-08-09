-- ~/.config/nvim/lua/plugins/lspsaga.lua
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Hide top tabline, show bottom statusline
      vim.o.showtabline = 0 -- never show top
      vim.o.laststatus = 2 -- show bottom when at least one window

      vim.o.termguicolors = true
      vim.o.winbar = "" -- make sure winbar is empty

      local colors = {
        blue = "#80a0ff",
        green = "#a3be8c",
        violet = "#d183e8",
        black = "#1a1b26",
        white = "#c6c6c6",
        grey = "#303030",
        red = "#ff5189",
        cyan = "#79dac8",
      }

      local bubbles_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.blue },
          b = { fg = colors.white, bg = colors.grey },
          c = { fg = colors.white, bg = colors.black },
        },
        insert = {
          a = { fg = colors.black, bg = colors.green },
        },
        visual = {
          a = { fg = colors.black, bg = colors.violet },
        },
        replace = {
          a = { fg = colors.black, bg = colors.red },
        },
        inactive = {
          a = { fg = colors.white, bg = colors.black },
          b = { fg = colors.white, bg = colors.black },
          c = { fg = colors.white, bg = colors.black },
        },
      }

      require("lualine").setup({
        options = {
          theme = bubbles_theme,
          component_separators = "",
          section_separators = "",
          globalstatus = true,
        },

        -- Bottom statusline sections
        sections = {
          lualine_a = { "mode" }, -- current mode
          lualine_b = {
            {
              -- show a dot only if the buffer is modified
              function()
                return vim.bo.modified and "●" or ""
              end,
              color = { fg = colors.red },
              cond = function()
                return vim.bo.modified
              end,
            },
          },
          lualine_c = {
            {
              function()
                local name = vim.api.nvim_buf_get_name(0)
                if name == "" then
                  return "[No Name]"
                end
                local rel = vim.fn.fnamemodify(name, ":.") -- relative to CWD if possible
                return rel:sub(1, 1) == "/" and vim.fn.fnamemodify(name, ":p") or rel
              end,
            },
          },

          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },

        -- No inactive sections
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },

        extensions = {},
      })
    end,
  },
}
