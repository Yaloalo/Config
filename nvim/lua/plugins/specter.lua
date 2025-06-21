-- lua/plugins/spectre.lua
return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd          = { "Spectre", "SpectreOpen" },
  keys = {
    {
      "<leader>pc",
      function()
        require("spectre").open_file_search({ select_word = true })
      end,
      desc = "pf: Spectre ▶ replace in current file",
    },
    {
      "<leader>pw",
      function()
        require("spectre").open()
      end,
      desc = "pc: Spectre ▶ search/replace in cwd",
    },
    {
      "<leader>pd",
      function()
        local actions      = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        require("telescope.builtin").find_files({
          prompt_title = "Pick Dir for Spectre",
          cwd          = vim.fn.getcwd(),
          find_command = { "fd", "-t", "d", "--hidden", "--no-ignore" },
          attach_mappings = function(prompt_bufnr, map_)
            actions.select_default:replace(function()
              local entry = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              local dir = entry.value
              if not vim.startswith(dir, "/") then
                dir = vim.fn.getcwd() .. "/" .. dir
              end
              require("spectre").open({ cwd = dir })
            end)
            return true
          end,
        })
      end,
      desc = "pd: Spectre ▶ pick subdir then search",
    },
  },
  config = function()
    require("spectre").setup({
      -- UI
      open_cmd         = "vnew",    -- split window; alternatives: 'tabedit', 'floating'
      is_insert_mode   = false,     -- start in normal mode
      color_devicons   = true,
      live_update      = true,
      lnum_for_results = true,
      -- use default mappings & engines to avoid the 'pairs got string' error
    })
  end,
}
