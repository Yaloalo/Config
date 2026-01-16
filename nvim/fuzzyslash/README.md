# FuzzySlash

FuzzySlash is a tiny Neovim plugin that mimics `/` search but matches fuzzily (subsequence). Type a query, see live highlights, press Enter to lock it in, and move through results with `n` / `N`.

## Features
- Live fuzzy highlights in the current buffer while you type.
- Press Enter to keep the search active; `n` / `N` jump between hits.
- Status component `require('fuzzyslash').status()` that shows `[current/total]`.
- Commands: `:FuzzySlash` to start, `:FuzzySlashStop` to clear.

## Requirements
- Neovim 0.9+ (uses modern Lua APIs).

## Install (example: lazy.nvim)
```lua
{
  'user/fuzzyslash',
  config = function()
    require('fuzzyslash').setup({
      prompt = 'fuzzy/',
      smart_case = true,
      min_query = 1,
      move_cursor = true,
    })
    -- Start the fuzzy search prompt (acts like `/` but fuzzy)
    vim.keymap.set('n', '<leader>/', function()
      require('fuzzyslash').start()
    end, { desc = 'Fuzzy buffer search' })
  end,
}
```

## Usage
- Trigger `:FuzzySlash` (or your keymap). Type to see live fuzzy matches.
- `<CR>` locks the search; `n` / `N` navigate the matches for the current buffer and window.
- `<Esc>` or `<C-c>` cancels and clears highlights. `:FuzzySlashStop` also clears.
- Add `require('fuzzyslash').status()` to your statusline/winbar to show counts (e.g., `%{%v:lua.require'fuzzyslash'.status()%}` in a `statusline` string).

## Notes
- Matching is subsequence-based (e.g., `fsl` matches `fuzzy search live`), respecting `smart_case` like `/`.
- Keymaps for `n` / `N` are buffer-local and restored when the search ends.
- Highlights: `FuzzySlashMatch` (links to `Search`) and `FuzzySlashCurrent` (links to `IncSearch`) are defined by default; override them if you want different colors.
