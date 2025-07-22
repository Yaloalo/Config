-- lua/plugins/init.lua
return {
  require("plugins.toggelterm"), --terminal
  require("plugins.oil"), --Buffer editor
  require("plugins.lspsaga"), -- LSp Stuff
  require("plugins.lspconfig"), -- Mote Slp suff
  require("plugins.conform"), -- Autoformat
  require("plugins.mason"), -- LSP
  require("plugins.indent_line"), --Line indetation
  require("plugins.render-markdown"), --Obvious
  require("plugins.telescope"), --Search files
  require("plugins.treesitter"), -- Color
  require("plugins.autopairs"), --Automtic closing brackets
  require("plugins.ui"), --looks nice
  require("plugins.harpoon"), --jumps
  require("plugins.lush"),
  require("plugins.rainbow_brackets"),
}
