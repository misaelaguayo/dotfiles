local function jj_commit_id(rev)
    local res = vim.system({ "jj", "log", "-r", rev, "--no-graph", "-T", "commit_id" }, { text = true }):wait()
    if res.code ~= 0 then
        vim.notify("jj: " .. (res.stderr or ""), vim.log.levels.ERROR)
        return nil
    end
    return vim.trim(res.stdout)
end

local function review_working_copy()
    if not vim.fs.root(0, ".jj") then
        vim.cmd("DiffviewOpen")
        return
    end
    local parent = jj_commit_id("@-")
    if parent then
        vim.cmd("DiffviewOpen " .. parent)
    end
end

local function review_log_rev()
    local rev_lines = vim.b.jj_log_rev_lines or {}
    local line = vim.api.nvim_win_get_cursor(0)[1]
    for i = line, 1, -1 do
        local rev = rev_lines[tostring(i)]
        if rev then
            local commit = jj_commit_id(rev)
            if commit then
                vim.cmd("DiffviewOpen " .. commit .. "^!")
            end
            return
        end
    end
end

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
            { "<space>gs", review_working_copy, desc = "Review working copy" },
            { "<space>gS", "<cmd>J status<CR>", desc = "jj status" },
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
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("UserJjLog", { clear = true }),
                pattern = "jj-log*",
                callback = function(ev)
                    vim.keymap.set("n", "gd", review_log_rev, { buffer = ev.buf, desc = "Review revision" })
                end,
            })
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
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        opts = function()
            local close = { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" } }
            return {
                enhanced_diff_hl = true,
                keymaps = {
                    view = { close },
                    file_panel = { close },
                    file_history_panel = { close },
                },
            }
        end,
    },
}
