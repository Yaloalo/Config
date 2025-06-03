
return {
  "ggandor/leap.nvim",
  config = function()
    local leap = require("leap")
    leap.set_default_mappings()
    leap.opts.preview_filter = function(ch0, ch1, ch2)
      if ch1:match("%s") then
        return false
      end
      if ch0:match("%a") and ch1:match("%a") and ch2:match("%a") then
        return false
      end
      return true
    end
    leap.opts.equivalence_classes = {
      " \t\r\n",
      "([{",
      ")]}",
      [["'"`]],
      "aäàáâãā",
      "eëéèêē",
      "iïīíìî",
      "oōóòôõ",
      "uūúùûü",
      "nñ",
      "sṣšß",
    }
    vim.keymap.set({ "n", "x", "o" }, "gs", function()
      require("leap.remote").action()
    end, { desc = "Leap-remote (perform action at remote target)" })
  end,
}
