## Purpose of this nvim config
      
This is my personal config; I have altered a lot of stuff except the basic keybindings.  
The goal was to do everything in nvim, except debugging, which I have not been able to make work with QEMU.

## Structure

```

.
├── init.lua
├── lazy-lock.json
├── lua
│   ├── core
│   │   ├── autocmds.lua
│   │   ├── keymaps.lua
│   │   ├── options.lua
│   │   └── plugins.lua
│   └── plugins
│       ├── autopairs.lua
│       ├── blink.lua
│       ├── conform.lua
│       ├── dap.lua
│       ├── hardtime.lua
│       ├── indent\_line.lua
│       ├── init.lua
│       ├── lspconfig.lua
│       ├── lspsaga.lua
│       ├── mason.lua
│       ├── oil.lua
│       ├── render-markdown.lua
│       ├── snacks.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       ├── trouble.lua
│       └── ui.lua
└── README.md

```

---

## Core

### Auto

1. The first one is stolen from Kickstart and highlights yanked text
2. The second automatically reloads the nvim buffer
3. Trims whitespace (TrimWhitespace)
4. Fortune on startup

### keymaps

- Clear highlights
- Easier window navigation
- Alternative insert-mode movements
- Open my personal notes `<Leader>n`
- Close a buffer `<Leader>c`
- Change dir (fuzzy search from root, then Enter) `<Leader>w`
- Format buffer `<Leader>f`
- Open terminal `<Leader>t`

Now we get to some categories of keymaps: `<Leader-l>` is for LSP stuff:

- `A` – Code action
- `d` – Toggle diagnostics window (Trouble)
- `D` – Hover doc
- `H` – Calls
- `I` – Line diagnostic
- `O` – Outline
- `r` – Restart LSP server
- `R` – Rename symbol
- :W - save without autoformat
  The rest of the core setup is not that interesting.

---

## Plugins

So I have a lot of plugins that are really nice, also full LSP integration which can easily be ignored with the key to toggle LSP Info. I have tried to make everything look nice and round.

### [Oil](https://github.com/stevearc/oil.nvim)

Yeah, Oil is awesome. To use it, press `<Leader>o` to enter; then:

- `o` – open Oil in the current cwd
- `c` – open Oil in the parent directory of the current buffer file

### [Lspsaga](https://github.com/glepnir/lspsaga.nvim)

We have talked about Lspsaga already in the _Leader l_ section, but it mostly boils down to better LSP integration.

### [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

Not that interesting; just LSP setup stuff.

### [Trouble](https://github.com/folke/trouble.nvim)

A better window to see problems with the code – again, LSP stuff which we have talked about before.

### [Blink](https://github.com/Saghen/blink.nvim)

Blink is used for autocompletion. Ghost text is standard and can be accepted with `<C-y>`. Press `<Leader-C>` to open the suggestion window (scrollable with arrow keys); when you select an entry, just resume typing and it will be inserted automatically.

### [Conform](https://github.com/stevearc/conform.nvim)

Yeah, autoformat is nice; all my format files are in `~/.config/format` so I don’t rely on defaults.

### [Mason](https://github.com/williamboman/mason.nvim)

Yeah, obvious.

### [Hardtime](https://github.com/m4xshen/hardtime.nvim)

Skill issue.

### [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)

Yeah, I made the same grey lines.

### [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)

Nvim is my only note-taking app – here is a nice markdown renderer.

- Toggle Markdown render with `<Leader-m>`

### [Snacks](https://github.com/folke/snacks.nvim)

A collection of small QoL plugins (dashboard, notifier, terminal, etc.).

### [Telescope](https://github.com/nvim-telescope/telescope.nvim)

This is a big one. `<Leader-s>` modes:

- `f` – fuzzy find cwd
- `b` – open buffer
- `g` – live grep
- `n` – fuzzy Neovim config
- `r` – ranger-style file browser

…and the cwd key also uses Telescope.

### [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

Yeah, nothing all too special here – just highlighting.

### [Autopairs](https://github.com/windwp/nvim-autopairs)

Should also be obvious.

### UI

- Lua line
- A start screen
- Some other stuff to make everything look nice

_(UI plugins include [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) and [alpha-nvim](https://github.com/goolord/alpha-nvim))_

---

## End

I like it
