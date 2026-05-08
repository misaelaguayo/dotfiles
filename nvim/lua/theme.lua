vim.cmd [[colorscheme gruvbox]]

-- fugitive-core's ANSI parser (used by jj-fugitive's log/diff/show views) emits
-- highlight groups named after raw ANSI color names (Red, Green, BoldGreen, ...)
-- that are never otherwise defined, so those views render with no color at all.
-- Link them to gruvbox's palette so `:J log`/`:J diff`/`:J show` look right.
local function link_ansi_colors()
    local map = {
        Black = "GruvboxGray",
        Red = "GruvboxRed",
        Green = "GruvboxGreen",
        Yellow = "GruvboxYellow",
        Blue = "GruvboxBlue",
        Magenta = "GruvboxPurple",
        Cyan = "GruvboxAqua",
        White = "GruvboxFg1",
        DarkGray = "GruvboxGray",
        LightRed = "GruvboxRed",
        LightGreen = "GruvboxGreen",
        LightYellow = "GruvboxYellow",
        LightBlue = "GruvboxBlue",
        LightMagenta = "GruvboxPurple",
        LightCyan = "GruvboxAqua",
    }
    for name, target in pairs(map) do
        vim.api.nvim_set_hl(0, name, { link = target, default = true })
        vim.api.nvim_set_hl(0, "Bold" .. name, { link = target, bold = true, default = true })
    end
end

-- gruvbox sets SignColumn/FoldColumn's background to its "bg1" shade (lighter
-- than the main bg), so lines with a diff sign show a visibly different
-- gutter color than the text background and than EndOfBuffer's `~` filler.
-- Force the gutter to use the same background as the text itself.
local function fix_gutter_seam()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    if not normal.bg then
        return
    end
    for _, group in ipairs({ "SignColumn", "FoldColumn" }) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.bg = normal.bg
        vim.api.nvim_set_hl(0, group, hl)
    end
end

link_ansi_colors()
fix_gutter_seam()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UserTheme", { clear = true }),
    callback = function()
        link_ansi_colors()
        fix_gutter_seam()
    end,
})
