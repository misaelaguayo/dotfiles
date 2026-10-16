return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            }

            -- applies to every server, including ones mason-lspconfig auto-enables
            vim.lsp.config("*", { capabilities = capabilities })

            require("mason-lspconfig").setup({
                automatic_enable = {
                    exclude = {
                        "lua_ls",
                        "roslyn_ls",
                        "rust_analyzer",
                    },
                },
            })

            vim.lsp.config("rust_analyzer", {
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                        },
                    },
                },
            })

            vim.lsp.config("lua_ls", {
                cmd = { "lua-language-server" },
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            })

            -- installed through home-manager rather than mason
            vim.lsp.config("nixd", {
                settings = {
                    nixd = {
                        formatting = { command = { "nixfmt" } },
                    },
                },
            })

            vim.lsp.enable({ "rust_analyzer", "lua_ls", "nixd" })
        end,
    },
    { "williamboman/mason.nvim", opts = {} },
    "williamboman/mason-lspconfig.nvim",
    {
        "seblyng/roslyn.nvim",
        config = function()
            -- nixpkgs roslyn-ls doesn't support --daemon-mode, so override the default cmd
            vim.lsp.config("roslyn", {
                cmd = {
                    "Microsoft.CodeAnalysis.LanguageServer",
                    "--logLevel",
                    "Information",
                    "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
                    "--stdio",
                    "--clientProcessId",
                    tostring(vim.uv.os_getpid()),
                },
            })
            require("roslyn").setup({})
        end,
    },
    -- VS Code-style peek popup (gp / gR, set in LspAttach)
    { "dnlhc/glance.nvim", cmd = "Glance", opts = {} },
    -- live preview for <space>rn; loaded on LspAttach so the command preview
    -- works the first time (a lazy cmd stub wouldn't preview)
    { "smjonas/inc-rename.nvim", event = "LspAttach", opts = {} },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    -- completion
    "SirVer/ultisnips",
    "honza/vim-snippets",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "quangnguyen30192/cmp-nvim-ultisnips",
    "onsails/lspkind.nvim",
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require("cmp")
            local lspkind = require("lspkind")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.fn["UltiSnips#Anon"](args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "ultisnips" },
                }, {
                    { name = "path" },
                }),
                formatting = {
                    format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 }),
                },
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
            })
        end,
    },
}
