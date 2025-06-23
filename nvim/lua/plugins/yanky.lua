return {
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      ring = { history_length = 200 },
      -- blink highlight for only 100 ms
      highlight = { on_put = true, on_yank = true, timer = 100 },
      preserve_cursor_position = { enabled = true },
    },
    config = function(_, opts)
      require("yanky").setup(opts)

      -- load Telescope extension
      local has_telescope, telescope = pcall(require, "telescope")
      if has_telescope then
        telescope.load_extension("yank_history")
      end

      local map = vim.keymap.set

      -- Prevent clobbering registers on Visual-mode paste
      map("x", "p", "\"_dP", { desc = "Paste without clobbering registers" })
      map("x", "P", "\"_dP", { desc = "Paste without clobbering registers" })

      -- Yank-ring navigation under <leader>r*
      map({ "n","x" }, "<leader>rp", "<Plug>(YankyPutAfter)",   { desc = "Yank ▶ Put after" })
      map({ "n","x" }, "<leader>rP", "<Plug>(YankyPutBefore)",  { desc = "Yank ◀ Put before" })
      map("n",       "<leader>rn", "<Plug>(YankyNextEntry)",    { desc = "Yank ▶ Next entry" })
      map("n",       "<leader>rN", "<Plug>(YankyPreviousEntry)",{ desc = "Yank ◀ Previous entry" })

      -- <leader>rr → Telescope picker that sets the unnamed register on <CR>
      if has_telescope then
        map("n", "<leader>rr", function()
          local actions = require("yanky.telescope.mapping")
          local utils   = require("yanky.utils")
          telescope.extensions.yank_history.yank_history({
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.9,
              height = 0.6,
              preview_width = 0.5,
              prompt_position = "bottom",
            },
            preview = true,
            attach_mappings = function(_, map_)
              -- <CR> to set the selected entry into the unnamed register only
              map_("i", "<CR>", actions.set_register(utils.get_default_register()))
              map_("n", "<CR>", actions.set_register(utils.get_default_register()))
              return true
            end,
          })
        end, { desc = "Yank 🔍 Ring history (Telescope)" })
      else
        map("n", "<leader>rr", "<Cmd>YankyRingHistory<CR>", { desc = "Yank 🔍 Ring history" })
      end

      -- Force bright orange flash on yank/put
      vim.api.nvim_set_hl(0, "YankyYanked", { bg = "#FF8800", fg = nil })
      vim.api.nvim_set_hl(0, "YankyPut",    { bg = "#FF8800", fg = nil })
    end,
  },
}

