local editor_group = vim.api.nvim_create_augroup("UserEditor", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = editor_group,
    callback = function() vim.hl.on_yank() end,
})

-- reopen files at the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
    group = editor_group,
    callback = function(ev)
        local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        -- winbar breadcrumbs
        if client and client:supports_method("textDocument/documentSymbol") then
            require("nvim-navic").attach(client, ev.buf)
        end

        -- inline type/parameter hints
        if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end

        -- reference counts / "run test" links above functions (toggle with <space>cl)
        if client and client:supports_method("textDocument/codeLens") then
            vim.lsp.codelens.enable(true, { bufnr = ev.buf })
        end

        local function map(mode, lhs, rhs, desc, extra)
            vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = ev.buf, desc = desc }, extra or {}))
        end

        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        -- nowait: otherwise `gr` stalls waiting on nvim's built-in grn/grr/gra/gri
        -- trouble panel (docked at the bottom by edgy) instead of the raw quickfix list
        map("n", "gr", "<cmd>Trouble lsp_references toggle<CR>", "References", { nowait = true })
        map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
        map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
        map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
        map("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "List workspace folders")
        map("n", "<space>D", vim.lsp.buf.type_definition, "Type definition")
        -- inc-rename previews the new name across the buffer as you type
        map("n", "<space>rn", function()
            return ":IncRename " .. vim.fn.expand("<cword>")
        end, "Rename", { expr = true })
        map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, "Code action")
        -- peek in a popup without leaving the buffer
        map("n", "gp", "<cmd>Glance definitions<CR>", "Peek definition")
        map("n", "gR", "<cmd>Glance references<CR>", "Peek references")
        -- jump between the references snacks.words highlights; buffer-local so
        -- they win over ftplugin [[ / ]] section motions
        map("n", "]]", function() Snacks.words.jump(vim.v.count1) end, "Next reference")
        map("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev reference")
        map("n", "<space>cr", vim.lsp.codelens.run, "Run code lens")
        map("n", "<space>cl", function()
            vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
        end, "Toggle code lens")
        map("n", "<space>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
        end, "Toggle inlay hints")
    end,
})
