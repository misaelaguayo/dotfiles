return {
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
        "misaelaguayo/markdown.nvim",
        build = "cargo build --release",
        dev = true,
        opts = {
            converter_bin = "/Users/misaelaguayo/Projects/markdown.nvim/target/release/converter"
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
                    inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false,       -- add a border to hover docs and signature help
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
        "misaelaguayo/markdown.nvim",
        build = "cargo build --release",
        opts = {},
        dependencies = {
            {
                "3rd/image.nvim",
                build = false,
                opts = {
                    processor = "magick_cli",
                },
                config = function()
                    require("image").setup({
                        backend = "kitty",
                        processor = "magick_cli",
                    })
                end
            }
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
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup({
                view = { width = 50, },
            })
        end
    },
    {
        "julienvincent/hunk.nvim",
        cmd = { "DiffEditor" },
        config = function()
            require("hunk").setup({
                dependencies = {
                    "MunifTanjim/nui.nvim",
                }
            })
        end,
    },
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
    { "oknozor/illumination",             build = { "cd ~/.illumination", "./install.sh" } },
    "mfussenegger/nvim-dap",
    "milisims/nvim-luaref",
    "folke/which-key.nvim",
    { "folke/trouble.nvim",       opts = {},      cmd = "Trouble" },
    { "ellisonleao/gruvbox.nvim", priority = 1000 },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    "ms-jpq/coq_nvim",
    "ms-jpq/coq.artifacts",
    "junegunn/fzf",
    "junegunn/fzf.vim",
    "tpope/vim-fugitive",
    { "lewis6991/gitsigns.nvim",    config = function() require("gitsigns").setup() end },
    { "xiyaowong/transparent.nvim", config = function() require("transparent").setup() end },
    "SirVer/ultisnips",
    "honza/vim-snippets",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
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
    }
}
