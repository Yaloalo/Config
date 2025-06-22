-- lua/plugins/grug-far.lua
return {
  "MagicDuck/grug-far.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- Load on GrugFar commands or keymaps below
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    -- Replace in current file
    {
      "<leader>pc",
      function()
        require("grug-far").open({ prefills = { paths = vim.fn.expand("%:p") } })
      end,
      desc = "gf: GrugFar ▶ replace in current file",
    },
    -- Project-wide search/replace in cwd
    {
      "<leader>pw",
      function()
        require("grug-far").open()
      end,
      desc = "gf: GrugFar ▶ search/replace in cwd",
    },
    -- Pick a directory via Telescope, then search there
    {
      "<leader>pd",
      function()
        local actions      = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        require("telescope.builtin").find_files({
          prompt_title    = "Pick Dir for GrugFar",
          cwd             = vim.fn.getcwd(),
          find_command    = { "fd", "-t", "d", "--hidden", "--no-ignore" },
          attach_mappings = function(prompt_bufnr, map_)
            actions.select_default:replace(function()
              local entry = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              local dir = entry.value
              if not vim.startswith(dir, "/") then
                dir = vim.fn.getcwd() .. "/" .. dir
              end
              require("grug-far").open({ cwd = dir })
            end)
            return true
          end,
        })
      end,
      desc = "gf: GrugFar ▶ pick subdir then search",
    },
    -- In-buffer ripgrep search with <C-S>, then step through with n/N
    {
      "<C-S>",
      function()
        local pat = vim.fn.input('rg ❯ ')
        if pat == '' then return end
        vim.fn.setreg('/', pat)                      -- highlight via search register
        vim.cmd('silent grep! ' .. vim.fn.shellescape(pat) .. ' %')
      end,
      desc = "rg: in-buffer ripgrep search",
    },
  },
  config = function()
    -- Core plugin setup
    require("grug-far").setup({})

    -- Navigate matches with wrapping
    vim.keymap.set("n", "n", function()
      local qf = vim.fn.getqflist({ idx = 0, size = 0 })
      if qf.idx < qf.size then
        vim.cmd("silent! cnext")
      else
        vim.cmd("silent! cfirst")
      end
    end, { desc = "grug: next match (wrap)" })

    vim.keymap.set("n", "N", function()
      local qf = vim.fn.getqflist({ idx = 0, size = 0 })
      if qf.idx > 1 then
        vim.cmd("silent! cprevious")
      else
        vim.cmd("silent! clast")
      end
    end, { desc = "grug: prev match (wrap)" })
  end,
}
