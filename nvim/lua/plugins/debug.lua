local function dap(fn, ...)
    local args = { ... }
    return function() require("dap")[fn](unpack(args)) end
end

local function widget(name)
    return function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets[name])
    end
end

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            -- variable values inline while stepping
            { "theHamsta/nvim-dap-virtual-text", opts = {} },
        },
        keys = {
            -- load dap first: its config sets up dapui, and requiring dapui on its
            -- own would load nvim-dap mid-require and loop
            { "<space>du", function() require("dap"); require("dapui").toggle() end, desc = "Debug: toggle UI" },
            { "<space>n", dap("new"), desc = "Debug: new session" },
            { "<space>dc", dap("continue"), desc = "Debug: continue" },
            { "<space>t", dap("toggle_breakpoint"), desc = "Debug: toggle breakpoint" },
            { "<F5>", dap("continue"), desc = "Debug: continue" },
            { "<F10>", dap("step_over"), desc = "Debug: step over" },
            { "<F11>", dap("step_into"), desc = "Debug: step into" },
            { "<F12>", dap("step_out"), desc = "Debug: step out" },
            {
                "<Leader>lp",
                function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
                desc = "Debug: log point",
            },
            { "<Leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: toggle REPL" },
            { "<Leader>dl", dap("run_last"), desc = "Debug: run last" },
            { "<Leader>dh", function() require("dap.ui.widgets").hover() end, mode = { "n", "v" }, desc = "Debug: hover" },
            { "<Leader>dp", function() require("dap.ui.widgets").preview() end, mode = { "n", "v" }, desc = "Debug: preview" },
            { "<Leader>df", widget("frames"), desc = "Debug: frames" },
            { "<Leader>ds", widget("scopes"), desc = "Debug: scopes" },
        },
        config = function()
            local d = require("dap")

            -- variables / stack / watches / breakpoints panels, opened and
            -- closed with each debug session
            local dapui = require("dapui")
            dapui.setup()
            d.listeners.before.attach.dapui_config = dapui.open
            d.listeners.before.launch.dapui_config = dapui.open
            d.listeners.before.event_terminated.dapui_config = dapui.close
            d.listeners.before.event_exited.dapui_config = dapui.close

            d.adapters.coreclr = {
                type = "executable",
                command = "netcoredbg",
                args = { "--interpreter=vscode" },
            }

            d.configurations.cs = {
                {
                    type = "coreclr",
                    name = "launch - netcoredbg",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
                    end,
                },
            }

            d.adapters.lldb = {
                type = "executable",
                command = "lldb-dap",
                name = "lldb",
            }

            d.configurations.rust = {
                {
                    name = "Launch",
                    type = "lldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = true,
                    args = {},
                },
            }
        end,
    },
}
