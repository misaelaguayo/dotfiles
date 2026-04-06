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

vim.lsp.config('roslyn_ls', {
    capabilities = capabilities,
    filetypes = { "cs" },
    cmd = {
        "Microsoft.CodeAnalysis.LanguageServer",
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
        "--stdio",
    },
    handlers = {
        ["razor/provideDynamicFileInfo"] = function(_, _, _)
            vim.notify(
                'Razor is not supported',
                vim.log.levels.WARN,
                { title = 'roslyn_ls' }
            )
            return vim.NIL
        end,
        ["workspace/_roslyn_projectHasUnresolvedDependencies"] = function()
            vim.notify('Detected missing dependencies. Run `dotnet restore` command.', vim.log.levels.ERROR, {
                title = 'roslyn_ls',
            })
            return vim.NIL
        end,
        ["workspace/_roslyn_projectNeedsRestore"] = function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

            ---@diagnostic disable-next-line: param-type-mismatch
            client:request('workspace/_roslyn_restore', result, function(err, response)
                if err then
                    vim.notify(err.message, vim.log.levels.ERROR, { title = 'roslyn_ls' })
                end
                if response then
                    for _, v in ipairs(response) do
                        vim.notify(v.message, vim.log.levels.INFO, { title = 'roslyn_ls' })
                    end
                end
            end)

            return vim.NIL
        end,
    },
    settings = {
        ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles"
        },
        ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = false,
            dotnet_enable_tests_code_lens = false
        },
        ["csharp|completion"] = {
            dotnet_provide_regex_completions = false,
            dotnet_show_completion_items_from_unimported_namespaces = false,
            dotnet_show_name_completion_suggestions = false
        },
        ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = false,
            csharp_enable_inlay_hints_for_implicit_variable_types = false,
            csharp_enable_inlay_hints_for_lambda_parameter_types = false,
            csharp_enable_inlay_hints_for_types = false,
            dotnet_enable_inlay_hints_for_indexer_parameters = false,
            dotnet_enable_inlay_hints_for_literal_parameters = false,
            dotnet_enable_inlay_hints_for_object_creation_parameters = false,
            dotnet_enable_inlay_hints_for_other_parameters = false,
            dotnet_enable_inlay_hints_for_parameters = false,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false
        },
        ["csharp|symbol_search"] = {
            dotnet_search_reference_assemblies = false
        }
    },
})

vim.lsp.enable("roslyn_ls")
