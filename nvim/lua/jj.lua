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
    local root = jj_root(bufnr)
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

return {
    jump_hunk = jump_hunk,
    preview_hunk = preview_hunk,
    reset_hunk = reset_hunk,
    reset_buffer = reset_buffer,
}
