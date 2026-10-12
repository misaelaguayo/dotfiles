-- Global keymaps. Plugin-specific ones live in that plugin's `keys` spec under
-- lua/plugins/, and LSP buffer-local ones in autocmds.lua.

local map = vim.keymap.set

map("n", "<CR>", "<cmd>noh<CR><CR>", { desc = "Clear search highlight" })
map("n", "<Leader>w", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })
map("n", "<Leader>c", "<cmd>cclose<CR>", { desc = "Close quickfix" })

-- buffers
map("n", "<space>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<space>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<space>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<space>bb", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close other buffers" })

-- diagnostics
map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, _highest = true, on_jump = vim.diagnostic.open_float })
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, _highest = true, on_jump = vim.diagnostic.open_float })
end, { desc = "Next diagnostic" })
map("n", "<space>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- hunks: gitsigns in git repos, lua/jj.lua in jj repos
local jj = require("jj")
map("n", "<space>gj", function() jj.jump_hunk(1) end, { desc = "Next hunk" })
map("n", "<space>gk", function() jj.jump_hunk(-1) end, { desc = "Prev hunk" })
map("n", "<space>gp", jj.preview_hunk, { desc = "Preview hunk" })
map("n", "<space>gr", jj.reset_hunk, { desc = "Reset hunk" })
map("n", "<space>gR", jj.reset_buffer, { desc = "Reset buffer" })
