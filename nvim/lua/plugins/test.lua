local plugin_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "fuzzyslash")

return  {
    dir = plugin_dir,
    name = "fuzzyslash",
    config = function()
      require("fuzzyslash").setup({
        prompt = "fuzzy/",
        smart_case = true,
        min_query = 1,
        move_cursor = true,
      })
      vim.keymap.set("n", "<leader>/", function()
        require("fuzzyslash").start()
      end, { desc = "Fuzzy buffer search" })
    end,
  }
