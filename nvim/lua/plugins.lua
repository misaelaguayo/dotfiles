return {
    {
        "seblyng/roslyn.nvim",
        opts = {
            cmd = {
                "dotnet",
                "Microsoft.CodeAnalysis.LanguageServer",
                "--logLevel",
                "Information",
                "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
                "--stdio",
            },
        },
    },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            cmdline = {
                enabled = true,
                view = "cmdline",
            },
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                lsp = {
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                presets = {
                    bottom_search = true,         -- use a classic bottom cmdline for search
                    command_palette = true,       -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false,            -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false,        -- add a border to hover docs and signature help
                },
            })
        end,
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nsidorenco/neotest-vstest",
            "marilari88/neotest-vitest"
        }
    },
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                -- registries = {
                --     "github:mason-org/mason-registry",
                --     "github:CrashDummyy/mason-registry",
                -- },
            })
        end
    },
    { "williamboman/mason-lspconfig.nvim" },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            -- powers the "w" mapping (open_with_window_picker)
            {
                "s1n7ax/nvim-window-picker",
                name = "window-picker",
                version = "2.*",
                config = function()
                    require("window-picker").setup()
                end,
            },
        },
        cmd = "Neotree",
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                popup_border_style = "rounded",
                window = { width = 40 },
                default_component_configs = {
                    indent = { with_expanders = true },
                    git_status = {
                        symbols = {
                            added = "",
                            modified = "",
                            deleted = "",
                            renamed = "",
                            untracked = "",
                            ignored = "",
                            unstaged = "",
                            staged = "",
                            conflict = "",
                        },
                    },
                    diagnostics = {
                        symbols = { hint = "", info = "", warn = "", error = "" },
                    },
                },
                filesystem = {
                    follow_current_file = { enabled = true },
                    use_libuv_file_watcher = true,
                    filtered_items = { hide_dotfiles = false, hide_gitignored = false },
                },
                source_selector = {
                    winbar = true,
                    sources = {
                        { source = "filesystem", display_name = "  Files" },
                        { source = "git_status",  display_name = "  Git" },
                    },
                },
            })
        end,
    },
    {
        "julienvincent/hunk.nvim",
        cmd = { "DiffEditor" },
        config = function()
            require("hunk").setup({
                ui = {
                    layout = "vertical",
                    tree = {
                        width = 40,
                        float = {
                            border = "rounded",
                        },
                    },
                },
            })
        end,
    },
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
    "milisims/nvim-luaref",
    {
        "direnv/direnv.vim",
        event = "VeryLazy",
        init = function()
            vim.g.direnv_auto = 1
        end,
    },
    {
        "martintrojer/jj-fugitive",
        dependencies = { "martintrojer/fugitive-core.nvim" },
        cmd = { "J" },
        config = function()
            require("jj-fugitive").setup({
                default_command = "log",
                open_mode = "split",
            })
            -- fugitive-core only distinguishes "split" (horizontal) vs "tab";
            -- there's no vertical option, so default every pane it opens
            -- (log/status/diff/describe) to vsplit unless a call site
            -- explicitly asks for something else (e.g. annotate's "botright split").
            local ui = require("fugitive-core.ui")
            local open_pane = ui.open_pane
            ui.open_pane = function(opts)
                opts = opts or {}
                opts.split_cmd = opts.split_cmd or "vsplit"
                return open_pane(opts)
            end
        end,
    },
    {
        "evanphx/jjsigns.nvim",
        event = "VeryLazy",
        config = function()
            require("jjsigns").setup()
        end,
    },
    -- conflict resolution: mergiraf (set as jj's default merge-editor) handles
    -- what it can automatically; for anything left over, `jj resolve --tool
    -- diffconflicts <path>` opens this git-style 3-way merge in nvim (wired up
    -- in ~/.config/jj/config.toml).
    { "whiteinge/diffconflicts", cmd = { "DiffConflicts", "DiffConflictsWithHistory" } },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
    },
    { "folke/trouble.nvim",       opts = {},      cmd = "Trouble" },
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                contrast = "hard",
                italic = {
                    strings = false,
                    comments = true,
                    operators = false,
                    folds = true,
                },
            })
        end,
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup({
                options = { theme = 'gruvbox' },
                winbar = {
                    lualine_c = {
                        {
                            function() return require("nvim-navic").get_location() end,
                            cond = function() return require("nvim-navic").is_available() end,
                        },
                    },
                },
                inactive_winbar = {
                    lualine_c = {
                        {
                            function() return require("nvim-navic").get_location() end,
                            cond = function() return require("nvim-navic").is_available() end,
                        },
                    },
                },
            })
        end,
    },
    -- breadcrumbs (LSP document symbol path) in the winbar
    { "SmiteshP/nvim-navic", lazy = true },
    -- symbols outline sidebar, like an IDE's "Outline"/"Structure" panel
    {
        "stevearc/aerial.nvim",
        cmd = { "AerialToggle" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {
            layout = { width = 35 },
            attach_mode = "global",
        },
    },
    -- prettier vim.ui.select / vim.ui.input (rename dialogs, code actions, etc.)
    { "stevearc/dressing.nvim", event = "VeryLazy", opts = {} },
    -- dock neo-tree / aerial / trouble as fixed IDE-style side/bottom panels
    {
        "folke/edgy.nvim",
        event = "VeryLazy",
        opts = {
            left = {
                { ft = "neo-tree", title = "Explorer", size = { width = 40 } },
                { ft = "aerial",   title = "Outline",   size = { width = 35 } },
            },
            bottom = {
                { ft = "trouble", size = { height = 12 } },
                { ft = "qf",      title = "QuickFix" },
            },
        },
    },
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("fzf-lua").setup({
                fzf_colors = true,
                winopts = {
                    border = "rounded",
                    preview = { border = "rounded" },
                },
            })
        end,
    },
    "tpope/vim-fugitive",
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                -- jjsigns.nvim owns the gutter for jj repos (including
                -- colocated ones) so both plugins don't draw signs at once.
                on_attach = function(bufnr)
                    local root = vim.fs.root(bufnr, ".jj")
                    if root then
                        return false
                    end
                end,
                preview_config = {
                    border = "rounded",
                },
                current_line_blame = true,
                current_line_blame_opts = {
                    delay = 300,
                },
            })
        end,
    },
    { "xiyaowong/transparent.nvim", config = function() require("transparent").setup() end },
    "SirVer/ultisnips",
    "honza/vim-snippets",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
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
    "sindrets/diffview.nvim",
    "quangnguyen30192/cmp-nvim-ultisnips",
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup {}
        end,
    },
    { "numToStr/Comment.nvim", config = function() require('Comment').setup() end },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query",
                    "rust", "c_sharp",
                    "typescript", "tsx", "javascript",
                    "json", "yaml", "toml",
                    "markdown", "markdown_inline",
                    "bash", "html", "css", "diff", "gitcommit",
                },
                highlight = { enable = true },
                indent = { enable = true },
                fold = { enable = true },
            })
        end,
    },
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "VeryLazy",
        config = function()
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
            require("ufo").setup()
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "VeryLazy",
        opts = {},
    },
    {
        "brenoprata10/nvim-highlight-colors",
        event = "VeryLazy",
        config = function()
            require("nvim-highlight-colors").setup({})
        end,
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {},
    },
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VimEnter",
        config = function()
            local dashboard = require("alpha.themes.dashboard")
            dashboard.section.header.val = {
                "                                                     ",
                "  ███╗   ██╗██╗   ██╗██╗███╗   ███╗                 ",
                "  ████╗  ██║██║   ██║██║████╗ ████║                 ",
                "  ██╔██╗ ██║██║   ██║██║██╔████╔██║                 ",
                "  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║                 ",
                "  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║                 ",
                "  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝                 ",
                "                                                     ",
            }
            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find file", ":FzfLua files<CR>"),
                dashboard.button("r", "  Recent files", ":FzfLua oldfiles<CR>"),
                dashboard.button("g", "  Find word", ":FzfLua live_grep<CR>"),
                dashboard.button("e", "  New file", ":enew<CR>"),
                dashboard.button("q", "  Quit", ":qa<CR>"),
            }
            require("alpha").setup(dashboard.config)
        end,
    },
}
