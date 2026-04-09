require("neotest").setup({
    adapters = {
        require("neotest-vitest"){
            is_test_file = function(file_path)
                return file_path:match("%.test%.tsx?$")
            end,
            vitest_args = { "--mode", "local-backend" }
        },
    }
})

local dap = require('dap')

dap.adapters.coreclr = {
    type = 'executable',
    command = '/Users/misael/.nix-profile/bin/netcoredbg',
    args = { '--interpreter=vscode' }
}

dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug' .. '/', 'file')
        end,
    },
}

dap.adapters.lldb = {
    type = 'executable',
    command = '/Users/misael/.nix-profile/bin/lldb-dap',
    name = 'lldb',
}

dap.configurations.rust = {
    {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug' .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = true,
        args = {},
    }
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities()

capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

require("mason-lspconfig").setup {
    automatic_enable = {
        exclude = {
            "lua_ls",
            "roslyn_ls",
            "rust_analyzer",
        },
    },
}

vim.lsp.config('rust_analyzer', {
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
            },
            checkOnSave = {
            },
        },
    },
})

vim.lsp.enable("rust_analyzer")

vim.lsp.config('lua_ls', {
    capabilities = capabilities,
    cmd = { "lua-language-server" },
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' },
            },
        },
    },
})

vim.lsp.enable('lua_ls')
