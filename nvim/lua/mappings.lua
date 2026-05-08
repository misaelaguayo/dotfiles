vim.g.UltiSnipsExpandTrigger = "<tab>"
vim.g.UltiSnipsJumpForwardTrigger = "<c-b>"
vim.g.UltiSnipsJumpBackwardTrigger = "<c-z>"

vim.opt.wrap = false
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.background = 'dark'
vim.opt.number = true
vim.opt.fixeol = false

vim.opt.termguicolors = true

vim.cmd('filetype plugin indent on')
vim.cmd('syntax on')

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.laststatus = 2

vim.keymap.set('n', '<CR>', ':noh<CR><CR>', { noremap = true })
vim.keymap.set('n', '<C-f>', ':FzfLua files<CR>', { noremap = true })
-- live_grep sends the query straight to ripgrep as regex on every keystroke
-- so patterns like `fn \w+\(string, string\) ->` work as typed.
vim.keymap.set('n', '<Leader>f', ':FzfLua live_grep<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>fs', ':FzfLua lsp_live_workspace_symbols<CR>', { noremap = true, desc = "Find symbol (functions, etc.)" })
vim.keymap.set('n', '<Leader>w', ':set wrap!<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>c', ':cclose<CR>', { noremap = true })

-- buffers
vim.keymap.set('n', '<Leader>b', ':FzfLua buffers<CR>', { noremap = true })
vim.keymap.set('n', '<space>bd', ':bdelete<CR>', { noremap = true })
vim.keymap.set('n', '<space>bn', ':bnext<CR>', { noremap = true })
vim.keymap.set('n', '<space>bp', ':bprevious<CR>', { noremap = true })
vim.keymap.set('n', '<space>bb', ':BufferLineCloseOthers<CR>', { noremap = true })

-- disable netrw at the very
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- file explorer / outline keybindings
vim.keymap.set('n', '<space>e', ':Neotree toggle reveal<CR>')
vim.keymap.set('n', '<space>o', ':AerialToggle<CR>', { desc = "Toggle symbols outline" })

-- nvim dap keybindings

vim.keymap.set('n', '<space>n', ':lua require"dap".new()<CR>', { noremap = true })
vim.keymap.set('n', '<space>c', ':lua require"dap".continue()<CR>', { noremap = true })
vim.keymap.set('n', '<space>t', ':lua require"dap".toggle_breakpoint()<CR>', { noremap = true })
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>lp',
    function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.toggle() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
    require('dap.ui.widgets').hover()
end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
    require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
end)


-- transparent keybindings
-- vim.keymap.set('n', '<space>t', ':TransparentToggle<CR>')

vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, _highest = true, on_jump = vim.diagnostic.open_float }) end)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, _highest = true, on_jump = vim.diagnostic.open_float }) end)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- folding (nvim-ufo)
vim.keymap.set('n', 'zR', function() require('ufo').openAllFolds() end)
vim.keymap.set('n', 'zM', function() require('ufo').closeAllFolds() end)

-- jjsigns has no hunk-navigation or preview commands of its own, so for jj
-- repos both are built from `jj diff` output here instead.
local function jj_root(bufnr)
    return vim.fs.root(bufnr, '.jj')
end

local function jump_hunk(dir)
    local bufnr = vim.api.nvim_get_current_buf()
    local root = jj_root(bufnr)
    if not root then
        vim.cmd(dir == 1 and 'Gitsigns next_hunk' or 'Gitsigns prev_hunk')
        return
    end

    local diff = require('jjsigns.diff')
    local hunks = diff.get_file_hunks(vim.api.nvim_buf_get_name(bufnr), root, '@-')
    if not hunks or #hunks == 0 then
        vim.notify('No jj hunks in this file', vim.log.levels.INFO)
        return
    end
    table.sort(hunks, function(a, b) return a.start_line < b.start_line end)

    local cur = vim.api.nvim_win_get_cursor(0)[1]
    local target
    if dir == 1 then
        for _, h in ipairs(hunks) do
            if h.start_line > cur then
                target = h
                break
            end
        end
        target = target or hunks[1]
    else
        for i = #hunks, 1, -1 do
            if hunks[i].start_line < cur then
                target = hunks[i]
                break
            end
        end
        target = target or hunks[#hunks]
    end
    vim.api.nvim_win_set_cursor(0, { target.start_line, 0 })
end

local function preview_hunk()
    local bufnr = vim.api.nvim_get_current_buf()
    local root = vim.fs.root(bufnr, '.jj')
    if not root then
        vim.cmd('Gitsigns preview_hunk')
        return
    end

    local jj = require('jjsigns.jj')
    local diff = require('jjsigns.diff')
    local abspath = vim.api.nvim_buf_get_name(bufnr)
    local relpath = abspath:sub(#root + 2)

    local lines = jj.command({ 'diff', '--git', '--context=3', '-r', '@-..@', '--', relpath }, { cwd = root })
    if not lines or #lines == 0 then
        vim.notify('No jj changes for this file', vim.log.levels.INFO)
        return
    end

    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local hunks = diff.parse_diff(lines)
    local target
    for _, h in ipairs(hunks) do
        if cur_line >= h.new_start and cur_line <= h.end_line then
            target = h
            break
        end
    end

    local block = {}
    local capturing = false
    for _, l in ipairs(lines) do
        local ns = l:match('^@@ %-%d+,?%d* %+(%d+)')
        if ns then
            if capturing then break end
            if target and tonumber(ns) == target.new_start then
                capturing = true
                table.insert(block, l)
            end
        elseif capturing then
            table.insert(block, l)
        end
    end
    if #block == 0 then
        block = lines
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, block)
    vim.bo[buf].filetype = 'diff'
    vim.bo[buf].modifiable = false
    -- Focused (not `enter = false`) so q/<Esc> are actually reachable, and so
    -- leaving it (WinLeave) is a reliable close signal regardless of how you leave.
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'cursor',
        row = 1,
        col = 0,
        width = math.min(90, vim.o.columns - 4),
        height = math.min(#block + 1, 20),
        border = 'rounded',
        style = 'minimal',
    })

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end
    vim.keymap.set('n', 'q', close, { buffer = buf, nowait = true })
    vim.keymap.set('n', '<Esc>', close, { buffer = buf, nowait = true })
    vim.api.nvim_create_autocmd('WinLeave', {
        buffer = buf,
        once = true,
        callback = close,
    })
end

-- jjsigns has no reset/restore command of its own either, so jj hunk/buffer
-- resets are done here by splicing in content read from the parent (@-).
-- Uses `jj file show` directly rather than jjsigns.jj.get_file_content, which
-- still shells out to the removed `jj cat` subcommand on jj 0.44+.
local function jj_file_at_parent(jj, relpath, root)
    local stdout, stderr, code = jj.command({ 'file', 'show', '-r', '@-', relpath }, { cwd = root })
    if code ~= 0 then
        vim.notify('jj error reading parent file: ' .. (stderr or ''), vim.log.levels.ERROR)
        return nil
    end
    return stdout
end

local function reset_hunk()
    local bufnr = vim.api.nvim_get_current_buf()
    local root = jj_root(bufnr)
    if not root then
        vim.cmd('Gitsigns reset_hunk')
        return
    end

    local jj = require('jjsigns.jj')
    local diff = require('jjsigns.diff')
    local abspath = vim.api.nvim_buf_get_name(bufnr)
    local relpath = abspath:sub(#root + 2)

    local diff_lines = jj.get_file_diff(relpath, '@-', '@', root)
    if not diff_lines or #diff_lines == 0 then
        vim.notify('No jj changes for this file', vim.log.levels.INFO)
        return
    end

    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local hunks = diff.parse_diff(diff_lines)
    local target
    for _, h in ipairs(hunks) do
        if cur_line >= h.start_line and cur_line <= math.max(h.end_line, h.start_line) then
            target = h
            break
        end
    end
    if not target then
        vim.notify('No jj hunk under cursor', vim.log.levels.INFO)
        return
    end

    local old_lines = jj_file_at_parent(jj, relpath, root)
    if not old_lines then
        return
    end

    local old_slice = {}
    for i = target.old_start, target.old_start + target.old_count - 1 do
        table.insert(old_slice, old_lines[i])
    end

    vim.api.nvim_buf_set_lines(bufnr, target.start_line - 1, target.end_line, false, old_slice)
end

local function reset_buffer()
    local bufnr = vim.api.nvim_get_current_buf()
    local root = jj_root(bufnr)
    if not root then
        vim.cmd('Gitsigns reset_buffer')
        return
    end

    local jj = require('jjsigns.jj')
    local abspath = vim.api.nvim_buf_get_name(bufnr)
    local relpath = abspath:sub(#root + 2)

    local old_lines = jj_file_at_parent(jj, relpath, root)
    if not old_lines then
        return
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, old_lines)
end

-- gitsigns keybindings (git repos) / jj dispatch via helpers above for jj repos
vim.keymap.set('n', '<space>gj', function() jump_hunk(1) end, { desc = "Next hunk" })
vim.keymap.set('n', '<space>gp', preview_hunk, { desc = "Preview hunk" })
vim.keymap.set('n', '<space>gk', function() jump_hunk(-1) end, { desc = "Prev hunk" })
vim.keymap.set('n', '<space>gr', reset_hunk, { desc = "Reset hunk" })
vim.keymap.set('n', '<space>gR', reset_buffer, { desc = "Reset buffer" })

-- jj-fugitive keybindings
vim.keymap.set('n', '<space>gg', ':J<CR>', { desc = "jj log" })
vim.keymap.set('n', '<space>gs', ':J status<CR>', { desc = "jj status" })
vim.keymap.set('n', '<space>gd', ':J diff<CR>', { desc = "jj diff" })

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        -- winbar breadcrumbs
        if client and client:supports_method('textDocument/documentSymbol') then
            require('nvim-navic').attach(client, ev.buf)
        end

        -- inline type/parameter hints
        if client and client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
        vim.keymap.set('n', '<space>ih', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
        end, vim.tbl_extend('force', opts, { desc = "Toggle inlay hints" }))
    end,
})

-- testing keybinds

vim.api.nvim_set_keymap(
    "n",
    "<leader>twr",
    "<cmd>lua require('neotest').run.run({ vitestCommand = 'vitest --watch' })<cr>",
    { desc = "Run Watch" }
)

vim.api.nvim_set_keymap(
    "n",
    "<leader>twf",
    "<cmd>lua require('neotest').run.run({ vim.fn.expand('%'), vitestCommand = 'vitest --watch' })<cr>",
    { desc = "Run Watch File" }
)

-- C# (vstest) testing keybinds
vim.keymap.set('n', '<leader>tcr', function() require('neotest').run.run() end, { desc = "Run nearest test" })
vim.keymap.set('n', '<leader>tcf', function() require('neotest').run.run(vim.fn.expand('%')) end, { desc = "Run test file" })
vim.keymap.set('n', '<leader>tcd', function() require('neotest').run.run({ strategy = "dap" }) end, { desc = "Debug nearest test" })
vim.keymap.set('n', '<leader>tco', function() require('neotest').output.open({ enter = true }) end, { desc = "Open test output" })
vim.keymap.set('n', '<leader>tcs', function() require('neotest').summary.toggle() end, { desc = "Toggle test summary" })
