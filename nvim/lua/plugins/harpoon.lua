return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-telescope/telescope.nvim" },

  opts = {
    menu = {
      width = vim.api.nvim_win_get_width(0) - 4,
    },
    settings = {
      save_on_toggle = true,
    },
  },

  keys = function()
    local keys = {
      {
        "<leader>ha",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon File",
      },
      {
        "<leader>hs",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Quick Menu",
      },
    }

    -- Go-to mappings for 1..9
    for i = 1, 9 do
      table.insert(keys, {
        "<leader>h" .. i,
        function()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon → File " .. i,
      })
    end

    -- Telescope-based picker
    table.insert(keys, {
      "<leader>hm",
      function()
        local harpoon = require("harpoon")
        local conf = require("telescope.config").values

        local function toggle_telescope(harpoon_files)
          local file_paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
          end

          require("telescope.pickers").new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
              results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
          }):find()
        end

        toggle_telescope(harpoon:list())
      end,
      desc = "Open Harpoon via Telescope",
    })

    -- 1) Remove the current buffer from Harpoon’s marks
    table.insert(keys, {
      "<leader>hr",
      function()
        require("harpoon"):list():remove()
      end,
      desc = "Harpoon Remove Current File",
    })

    -- 2) Remove by index: <leader>hd1, hd2, … hd9
    for i = 1, 9 do
      table.insert(keys, {
        "<leader>hd" .. i,
        function()
          require("harpoon"):list():removeAt(i)   -- ← use removeAt(i), not remove(i) :contentReference[oaicite:0]{index=0}
        end,
        desc = "Harpoon Remove File " .. i,
      })
    end

    return keys
  end,
}
