# Neovim

A deliberately small Neovim 0.12 setup. Each dependency has one clear job.

| Tool | Job |
| --- | --- |
| lazy.nvim | plugin loading and updates |
| Tokyo Night | black-hole colour theme |
| Lualine | status line |
| Which-Key | discoverable editor shortcuts |
| Telescope | files, grep, buffers, history, and keymap search |
| Oil | file browser |
| Conform | formatting |
| nvim-lspconfig + Mason | language servers |
| Treesitter | syntax parsing and highlighting |
| Fidget | LSP progress |

## Essential keys

- `Space Space`: files
- `Space /`: live grep
- `Space B`: buffers
- `Space E`: file browser
- `Space F`: format
- `Space K`: search all active keymaps
- `Space ?`: Which-Key overview
- `Space L D/R/A/N/H`: definition, references, action, rename, hover
- `Ctrl H/J/K/L`: move between splits
- `Ctrl N/M`: horizontal/vertical split

The desktop-wide shortcut atlas is available with `Super+F1`.
