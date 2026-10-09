# Neovim

This is the original full plugin setup, organised around one prefix per job and
a black, white, and infinity-blue visual direction. Lazy scans every file under
`lua/plugins/`; `plugins/init.lua` intentionally stays empty to avoid loading
the same specifications twice.

## Layout

- `lua/core/` — options, autocommands, global keys, plugin bootstrap, palette
- `lua/plugins/` — one focused plugin specification per file
- `fuzzyslash/` — local fuzzy search plugin

## Key map

Press `<Space>?` for the live WhichKey guide, or `<Space>sk` to search all
active mappings.

| Prefix | Job |
| --- | --- |
| `<Space>s` | Telescope search (`f` files, `g` grep, `s` word, `b` browser, `c` commits, `n` config, `k` keys, `r` resume) |
| `<Space>o` | File tools (`o` Oil cwd, `c` current file directory, `y` Yazi) |
| `<Space>l` | LSP navigation, symbols, diagnostics, rename, and actions |
| `<Space>h` | Harpoon add, menu, jump, reorder, and remove |
| `<Space>g` | Grug search/replace scopes |
| `<Space>r` | Yank ring history and navigation |
| `<Space>c` | Compiler Explorer and hex view |
| `<Space>x` | LaTeX compile, view, errors, TOC, and logs |
| `<Space>f` | Format current buffer |
| `<Space>/` | Fuzzy search inside current buffer |
| `<Space>t` | Toggle centred scrolling |

Navigation keeps the existing scheme: `<C-h/j/k/l>` moves between windows,
`<C-n>`/`<C-m>` split, `s`/`S` invoke Flash, and `<C-b>` toggles editor
transparency.

## Plugins kept

The configuration still includes the original completion/LSP setup, Telescope,
Oil, Yazi, Harpoon, Grug, Yanky, Flash, Treesitter, Conform, VimTeX, Compiler
Explorer, render-markdown, rainbow brackets, Alpha, mini.diff, comments,
autopairs, Lush, lualine, and the local fuzzy-buffer search.
