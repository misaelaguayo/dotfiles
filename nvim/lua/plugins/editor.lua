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
    -- main-branch rewrite: no `configs` module, keymaps are set by hand
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = "VeryLazy",
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })

            local select = require("nvim-treesitter-textobjects.select")
            for lhs, query in pairs({
                af = "@function.outer",
                ["if"] = "@function.inner",
                ac = "@class.outer",
                ic = "@class.inner",
                aa = "@parameter.outer",
                ia = "@parameter.inner",
            }) do
                vim.keymap.set({ "x", "o" }, lhs, function()
                    select.select_textobject(query, "textobjects")
                end, { desc = "Select " .. query })
            end

            local move = require("nvim-treesitter-textobjects.move")
            vim.keymap.set({ "n", "x", "o" }, "]f", function()
                move.goto_next_start("@function.outer", "textobjects")
            end, { desc = "Next function" })
            vim.keymap.set({ "n", "x", "o" }, "[f", function()
                move.goto_previous_start("@function.outer", "textobjects")
            end, { desc = "Prev function" })
        end,
    },
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = { "ConformInfo", "FormatToggle" },
        keys = {
            { "<space>f", function() require("conform").format({ async = true }) end, mode = { "n", "v" }, desc = "Format" },
            { "<space>uf", "<cmd>FormatToggle<CR>", desc = "Toggle format on save" },
        },
        opts = {
            -- anything not listed falls back to the language server's formatter
            formatters_by_ft = {
                rust = { "rustfmt" },
                nix = { "nixfmt" },
            },
            default_format_opts = { lsp_format = "fallback" },
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                return { timeout_ms = 1000 }
            end,
        },
        config = function(_, opts)
            require("conform").setup(opts)
            vim.api.nvim_create_user_command("FormatToggle", function()
                vim.g.disable_autoformat = not vim.g.disable_autoformat
                vim.notify("Format on save " .. (vim.g.disable_autoformat and "off" or "on"))
            end, {})
        end,
    },
    -- project-wide search and replace panel
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        keys = {
            {
                "<space>sr",
                function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,
                desc = "Search and replace (word)",
            },
            {
                "<space>sr",
                function() require("grug-far").with_visual_selection() end,
                mode = "x",
                desc = "Search and replace (selection)",
            },
        },
        opts = {},
    },
    -- only the `words` module: highlights LSP references to the symbol under
    -- the cursor; ]] / [[ to jump between them are set in LspAttach
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            words = { enabled = true },
        },
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
