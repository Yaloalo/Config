
-- lua/plugins/fm.lua
return {
  {
    'is0n/fm-nvim',
    -- load on any of the : commands
    cmd = {
      'Neomutt', 'Lazygit', 'Joshuto', 'Ranger', 'Broot', 'Gitui',
      'Xplr', 'Vifm', 'Skim', 'Nnn', 'Fff', 'Twf', 'Fzf', 'Fzy',
      'Lf', 'Fm', 'TaskWarriorTUI',
    },
    -- pass the defaults (you can trim or tweak any of these)
    opts = {
      edit_cmd = "edit",
      on_close  = {},
      on_open   = {},

      ui = {
        default = "float",
        float = {
          border    = "rounded",
          float_hl  = "Normal",
          border_hl = "FloatBorder",
          blend     = 0,
          height    = 0.8,
          width     = 0.8,
          x         = 0.5,
          y         = 0.5,
        },
        split = {
          direction = "topleft",
          size      = 24,
        },
      },

      cmds = {
        ranger_cmd      = "ranger",
      },

      mappings = {
        vert_split = "<C-v>",
        horz_split = "<C-h>",
        tabedit    = "<C-t>",
        edit       = "<C-e>",
        ESC        = "<ESC>",
      },

      broot_conf = vim.fn.stdpath("data")
        .. "/site/pack/packer/start/fm-nvim/assets/broot_conf.hjson",
    },
  },
}
