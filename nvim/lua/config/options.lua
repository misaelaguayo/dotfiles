-- Loaded before lazy.nvim so plugins see these on startup.

vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.background = "dark"
vim.opt.number = true
vim.opt.fixeol = false
vim.opt.termguicolors = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.laststatus = 3
vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.o.winborder = "rounded"

-- virtual_text is off by default since nvim 0.11, leaving only gutter signs
vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
    float = { border = "rounded" },
})

-- neo-tree replaces netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.UltiSnipsSnippetsDir = "$HOME/.config/nvim/UltiSnips"
vim.g.UltiSnipsExpandTrigger = "<tab>"
vim.g.UltiSnipsJumpForwardTrigger = "<c-b>"
vim.g.UltiSnipsJumpBackwardTrigger = "<c-z>"
