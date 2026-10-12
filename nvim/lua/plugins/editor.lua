return {
    -- `main` branch: a rewrite that only installs parsers/queries. Highlighting
    -- and indent are switched on per buffer below instead of via the old
    -- `nvim-treesitter.configs` modules. Compiling parsers needs the
    -- `tree-sitter` CLI (installed in home-manager/common.nix).
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false, -- the rewrite doesn't support lazy-loading
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "lua", "vim", "vimdoc", "query",
                "rust", "c_sharp",
                "typescript", "tsx", "javascript",
                "json", "yaml", "toml",
                "markdown", "markdown_inline",
                "bash", "html", "css", "diff", "gitcommit",
                "nix",
            })

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
                callback = function(ev)
                    -- fails quietly for filetypes with no installed parser
                    if pcall(vim.treesitter.start, ev.buf) then
                        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "VeryLazy",
        keys = {
            { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
            { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
        },
        init = function()
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
        end,
        opts = {},
    },
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = "FzfLua",
        keys = {
            { "<C-f>", "<cmd>FzfLua files<CR>", desc = "Find file" },
            -- live_grep sends the query straight to ripgrep as regex on every keystroke
            -- so patterns like `fn \w+\(string, string\) ->` work as typed.
            { "<Leader>f", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
            { "<Leader>s", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", desc = "Find symbol (functions, etc.)" },
            { "<Leader>b", "<cmd>FzfLua buffers<CR>", desc = "Find buffer" },
        },
        opts = {
            fzf_colors = true,
            winopts = {
                border = "rounded",
                preview = { border = "rounded" },
            },
        },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            -- powers the "w" mapping (open_with_window_picker)
            { "s1n7ax/nvim-window-picker", name = "window-picker", version = "2.*", opts = {} },
        },
        cmd = "Neotree",
        keys = {
            { "<space>e", "<cmd>Neotree toggle reveal<CR>", desc = "Toggle file explorer" },
        },
        opts = {
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
                    { source = "git_status", display_name = "  Git" },
                },
            },
        },
    },
    -- symbols outline sidebar, like an IDE's "Outline"/"Structure" panel
    {
        "stevearc/aerial.nvim",
        cmd = { "AerialToggle" },
        keys = {
            { "<space>o", "<cmd>AerialToggle<CR>", desc = "Toggle symbols outline" },
        },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {
            layout = { width = 35 },
            attach_mode = "global",
        },
    },
    { "numToStr/Comment.nvim", opts = {} },
    { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },
    {
        "direnv/direnv.vim",
        event = "VeryLazy",
        init = function()
            vim.g.direnv_auto = 1
        end,
    },
    "milisims/nvim-luaref",
}
