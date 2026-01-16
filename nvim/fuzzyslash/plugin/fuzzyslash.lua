if vim.g.loaded_fuzzyslash then
  return
end
vim.g.loaded_fuzzyslash = true

vim.api.nvim_create_user_command("FuzzySlash", function()
  require("fuzzyslash").start()
end, { desc = "Fuzzy search current buffer (like / but fuzzy)" })

vim.api.nvim_create_user_command("FuzzySlashStop", function()
  require("fuzzyslash").stop()
end, { desc = "Stop fuzzy search and clear highlights" })
