return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            -- jjsigns.nvim owns the gutter for jj repos (including
            -- colocated ones) so both plugins don't draw signs at once.
            on_attach = function(bufnr)
                if vim.fs.root(bufnr, ".jj") then
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
        },
    },
    { "evanphx/jjsigns.nvim", event = "VeryLazy", opts = {} },
    {
        "martintrojer/jj-fugitive",
        dependencies = { "martintrojer/fugitive-core.nvim" },
        cmd = { "J" },
        keys = {
            { "<space>gg", "<cmd>J<CR>", desc = "jj log" },
            { "<space>gs", "<cmd>J status<CR>", desc = "jj status" },
            { "<space>gd", "<cmd>J diff<CR>", desc = "jj diff" },
        },
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
    -- `jj split`/`jj diffedit` editor (ui.diff-editor in jj/config.toml)
    {
        "julienvincent/hunk.nvim",
        cmd = { "DiffEditor" },
        opts = {
            ui = {
                layout = "vertical",
                tree = {
                    width = 40,
                    float = {
                        border = "rounded",
                    },
                },
            },
        },
    },
    -- conflict resolution: mergiraf (set as jj's default merge-editor) handles
    -- what it can automatically; for anything left over, `jj resolve --tool
    -- diffconflicts <path>` opens this git-style 3-way merge in nvim (wired up
    -- in ~/.config/jj/config.toml).
    { "whiteinge/diffconflicts", cmd = { "DiffConflicts", "DiffConflictsWithHistory" } },
    "tpope/vim-fugitive",
    "sindrets/diffview.nvim",
}
