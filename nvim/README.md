# Neovim

Markdown-first setup: reading and navigating a notes repo, not writing code.
Organised around one prefix per job and a black, white, and infinity-blue
visual direction. Lazy scans every file under `lua/plugins/`;
`plugins/init.lua` intentionally stays empty to avoid loading the same
specifications twice.

## Layout

- `lua/core/` — options, autocommands, global keys, plugin bootstrap, palette,
  Markdown buffer behaviour (`markdown.lua`)
- `lua/plugins/` — one focused plugin specification per file
- `fuzzyslash/` — local fuzzy search plugin

## Key map

Press `<Space>?` for the keybinding browser (`lua/core/keymenu.lua`): plugins
first, `→` opens a plugin's keybindings, `→` again shows what one does (action,
where it is defined, and its code), `←` goes back. Typing filters each list.
`<Space>sk` is the flat, searchable list of all mappings. Pressing `<Space>`
and pausing shows the WhichKey popup.

| Key | Job |
| --- | --- |
| `<Space>e` / `<Space>E` | File tree toggle / focus (Neo-tree; `l` open, `h` close, `?` help, `<Tab>` edit mode) |
| `<Space>a` / `<Space>A` | Heading outline sidebar / floating outline |
| `<Space><Space>` | Open buffers |
| `<Space>s` | Telescope search (`f` files, `g` grep, `h` headings in all notes, `o` outline of this note, `B` backlinks, `s` word, `b` browser, `c` commits, `n` config, `k` keys, `r` resume) |
| `<Space>g` | Git (`c` commit all, `u` pull, `P` push, `s` sync = pull + push, `f` fetch now, `g` LazyGit, `l` log, `e` changed files, `p` preview change, `b` blame, `d` diff) |
| `<Space>n` | Notes in the vault (`n` new, `f` find, `s` search, `b` backlinks, `l` links, `t` tags, `d` today, `r` rename + update links, `c` checkbox, `p` paste image, `o` TOC) |
| `<Space>h` | Arrow file bookmarks: menu, then one key jumps (`s` toggle current file, `e` edit, `d` delete mode) |
| `<Space>H` | Arrow line bookmarks inside the current file |
| `<Space>q` | Sessions (`s` restore this dir, `l` last, `S` pick, `d` stop saving) |
| `<Space>o` | File tools (`o` Oil cwd, `c` current file directory, `y` Yazi) |
| `<Space>r` | Yank ring history and navigation |
| `<Space>u` | UI (`m` Markdown rendering, `w` wrap, `o` transparency, `c` cursor smear) |
| `<Space>/` | Fuzzy search inside current buffer |
| `<Space>t` | Toggle centred scrolling |

Git sync (`lua/core/git_sync.lua`). Statusline markers:

- `REMOTE: N` (red) — remote commits not pulled yet
- `LOCAL COMMITS: N` — local commits not pushed
- `UNCOMMITTED: N` — files with uncommitted changes in the repo
- `FILE: UNCOMMITTED` / `FILE: NEW` next to the file name — this file has
  uncommitted changes / is not tracked yet (`●` there still means unsaved)

The remote is fetched in the background every 5 minutes and on focus; the
local status is re-read on save, after Oil file operations and LazyGit. `<Space>gc`
saves the repo's open files, stages everything and asks for a message;
`<Space>gs` pulls (rebase + autostash) and then pushes. Conflicts are left for
LazyGit (`<Space>gg`).

File tree edit mode (`lua/core/oil_sidebar.lua`): `<Tab>` in the tree turns
the sidebar into Oil for the folder under the cursor. Type new lines to create
(`folder/`, `folder/sub/note.md`), edit names to rename, delete lines to
delete, then `<C-s>` (or `:w`) to apply. `<CR>` opens folders in place and
files in the main window, `-` goes up, `<Tab>` returns to the tree. In Oil,
`gv` opens in a vertical split and `gr` refreshes.

The obsidian.nvim vault is `~/projects/FIRM` (`lua/plugins/obsidian.lua`).
Inside it, `<CR>` is obsidian's smart action (follow link, toggle checkbox),
`[o` / `]o` jump between links, and typing `[[` or `#` completes notes and
tags. Frontmatter rewriting on save is disabled.

In other Markdown buffers: `<CR>` follows the link under the cursor
(`[text](file.md#heading)`, `[[wiki link]]`, URLs). Everywhere: `<BS>` jumps back, `{` / `}` jump between headings,
`za` folds a section, `]c` / `[c` jump between git changes. Rendering is
shown in normal mode and switches to raw text in insert mode.

Navigation keeps the existing scheme: `<C-h/j/k/l>` moves between windows,
`<C-n>`/`<C-m>` split, `s`/`S` invoke Flash, and `<C-b>` toggles editor
transparency.

## Plugins

render-markdown, obsidian.nvim, Neo-tree, Aerial, Telescope, Treesitter
(`main` branch), gitsigns, LazyGit, Oil, Yazi, Arrow, persistence, Flash,
Yanky, WhichKey, lualine, Alpha, Lush, stay-centered, and the local
fuzzy-buffer search.

Animation: smear-cursor, neoscroll (`<C-u>/<C-d>/<C-y>/<C-e>/zt/zz/zb`).
