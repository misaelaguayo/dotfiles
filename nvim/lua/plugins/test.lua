local function run(arg)
    return function() require("neotest").run.run(arg) end
end

return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nsidorenco/neotest-vstest",
            "marilari88/neotest-vitest",
        },
        keys = {
            -- vitest
            { "<leader>twr", run({ vitestCommand = "vitest --watch" }), desc = "Run Watch" },
            {
                "<leader>twf",
                function() require("neotest").run.run({ vim.fn.expand("%"), vitestCommand = "vitest --watch" }) end,
                desc = "Run Watch File",
            },
            -- C# (vstest)
            { "<leader>tcr", run(), desc = "Run nearest test" },
            { "<leader>tcf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run test file" },
            { "<leader>tcd", run({ strategy = "dap" }), desc = "Debug nearest test" },
            { "<leader>tco", function() require("neotest").output.open({ enter = true }) end, desc = "Open test output" },
            { "<leader>tcs", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
        },
        config = function()
            vim.g.neotest_vstest = {
                dap_settings = {
                    type = "coreclr",
                },
            }

            require("neotest").setup({
                adapters = {
                    require("neotest-vitest")({
                        is_test_file = function(file_path)
                            return file_path:match("%.test%.tsx?$")
                        end,
                        vitest_args = { "--mode", "local-backend" },
                    }),
                    require("neotest-vstest"),
                },
            })
        end,
    },
}
