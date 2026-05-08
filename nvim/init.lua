local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    dev = {
        path = "~/Projects"
    },
})

require("mappings")
require("theme")
require("lsp")
require("snips")

-- `:source $MYVIMRC` re-runs this file, including the `lazy.setup()` call
-- above, which lazy.nvim explicitly refuses to redo mid-session ("Re-sourcing
-- your config is not supported with lazy.nvim"). It also wouldn't help
-- anyway: require()'d modules are cached in package.loaded on first load, so
-- edits to mappings.lua/theme.lua/etc never re-run on a plain re-source.
-- Reload just those modules directly instead, skipping lazy entirely.
vim.api.nvim_create_user_command("ReloadConfig", function()
    local config_lua = vim.fn.stdpath("config") .. "/lua/"
    for _, name in ipairs({ "mappings", "theme", "lsp", "snips" }) do
        package.loaded[name] = nil
        dofile(config_lua .. name .. ".lua")
    end
    vim.notify("Config reloaded", vim.log.levels.INFO)
end, {})
