local function navic_location()
    return {
        function() return require("nvim-navic").get_location() end,
        cond = function() return require("nvim-navic").is_available() end,
    }
end

return {
    -- builds the colorscheme from Stylix's palette (lua/config/theme.lua)
    { "nvim-mini/mini.base16", priority = 1000 },
    -- fallback where Stylix isn't enabled (Mac, server)
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        opts = {
            contrast = "hard",
            italic = {
                strings = false,
                comments = true,
                operators = false,
                folds = true,
            },
        },
    },
    { "xiyaowong/transparent.nvim", opts = {} },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            -- derive statusline colors from whatever colorscheme is active
            options = { theme = "auto", globalstatus = true },
            winbar = { lualine_c = { navic_location() } },
            inactive_winbar = { lualine_c = { navic_location() } },
        },
    },
    -- breadcrumbs (LSP document symbol path) in the winbar
    { "SmiteshP/nvim-navic", lazy = true },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
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
                inc_rename = true,            -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false,       -- add a border to hover docs and signature help
            },
        },
    },
    -- prettier vim.ui.select / vim.ui.input (rename dialogs, code actions, etc.)
    { "stevearc/dressing.nvim", event = "VeryLazy", opts = {} },
    { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
    { "folke/trouble.nvim", cmd = "Trouble", opts = {} },
    -- dock neo-tree / aerial / trouble as fixed IDE-style side/bottom panels
    {
        "folke/edgy.nvim",
        event = "VeryLazy",
        opts = {
            left = {
                { ft = "neo-tree", title = "Explorer", size = { width = 40 } },
                { ft = "aerial", title = "Outline", size = { width = 35 } },
            },
            bottom = {
                { ft = "trouble", size = { height = 12 } },
                { ft = "qf", title = "QuickFix" },
            },
        },
    },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", event = "VeryLazy", opts = {} },
    { "brenoprata10/nvim-highlight-colors", event = "VeryLazy", opts = {} },
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
