-- lua/plugins/dap.lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "nvim-neotest/nvim-nio" },
      { "rcarriga/nvim-dap-ui", main = "dapui" },
      { "theHamsta/nvim-dap-virtual-text", main = "dapvt" },
    },
    event = "BufReadPost",
    config = function()
      -- log level for debugging
      local dap = require("dap")
      dap.set_log_level("DEBUG")

      -- virtual text & UI
      require("nvim-dap-virtual-text").setup()
      local dapui = require("dapui")
      dapui.setup()

      -- project root
      local cwd = vim.fn.getcwd()

      -- use GDB/MI (nvim-dap’s built-in MI→DAP translator)
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "-q", "--interpreter=mi2" },
      }

      -- attach config for C/C++
      dap.configurations.cpp = {
        {
          name = "Attach QEMU",
          type = "gdb",
          request = "launch",
          program = cwd .. "/build/boot/sys/core",
          cwd = cwd,
          stopOnEntry = false,
          setupCommands = {
            { text = "-enable-pretty-printing" },
            { text = "file " .. cwd .. "/build/boot/sys/core" },
            { text = "target remote localhost:3117" },
            { text = "break _start" },
          },
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- keymaps under <leader>d
      local function map(lhs, fn, desc)
        vim.keymap.set("n", lhs, fn, { silent = true, noremap = true, desc = desc })
      end

      map("<leader>dc", function()
        dap.continue()
        dapui.open()
      end, "DAP: Continue & Open UI")

      map("<leader>dd", function()
        dap.terminate()
        dapui.close()
      end, "DAP: Terminate")

      map("<leader>db", dap.toggle_breakpoint, "DAP: Toggle Breakpoint")
      map("<leader>do", dap.step_over, "DAP: Step Over")
      map("<leader>di", dap.step_into, "DAP: Step Into")
      map("<leader>du", dap.step_out, "DAP: Step Out")
      map("<leader>dr", dap.repl.open, "DAP: Open REPL")
      map("<leader>dl", dap.run_last, "DAP: Run Last")
    end,
  },
}
