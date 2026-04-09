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
vim.keymap.set('n', '<C-f>', ':Files<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>f', ':Rg<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>w', ':set wrap!<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>c', ':cclose<CR>', { noremap = true })

-- buffers
vim.keymap.set('n', '<Leader>b', ':Buffers<CR>', { noremap = true })
vim.keymap.set('n', '<space>bd', ':bdelete<CR>', { noremap = true })
vim.keymap.set('n', '<space>bn', ':bnext<CR>', { noremap = true })
vim.keymap.set('n', '<space>bp', ':bprevious<CR>', { noremap = true })
vim.keymap.set('n', '<space>bb', ':BufferLineCloseOthers<CR>', { noremap = true })

-- disable netrw at the very
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- nvim tree keybindings
vim.keymap.set('n', '<space>e', ':NvimTreeFindFileToggle<CR>')

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

-- gitsigns keybindings
vim.keymap.set('n', '<space>gj', ':Gitsigns next_hunk<CR>')
vim.keymap.set('n', '<space>gp', ':Gitsigns preview_hunk<CR>')
vim.keymap.set('n', '<space>gk', ':Gitsigns prev_hunk<CR>')
vim.keymap.set('n', '<space>gr', ':Gitsigns reset_hunk<CR>')
vim.keymap.set('n', '<space>gR', ':Gitsigns reset_buffer<CR>')

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

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
