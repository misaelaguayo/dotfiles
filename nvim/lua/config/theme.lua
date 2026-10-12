-- Colors follow Stylix: it writes the active base16 scheme to
-- ~/.config/stylix/palette.json and mini.base16 builds the colorscheme from
-- it. Without that file (Stylix not set up yet) it falls back to gruvbox.

local palette_path = vim.fn.expand("~/.config/stylix/palette.json")

-- Stylix's file stores bare hex ("1a1b26") alongside scheme metadata; return
-- just base00..base0F as "#rrggbb", which is what mini.base16 expects.
local function read_palette()
    local ok, lines = pcall(vim.fn.readfile, palette_path)
    if not ok or #lines == 0 then
        return nil
    end
    local decoded_ok, scheme = pcall(vim.json.decode, table.concat(lines, "\n"))
    if not decoded_ok then
        return nil
    end
    local palette = {}
    for i = 0, 15 do
        local key = ("base%02X"):format(i)
        if type(scheme[key]) ~= "string" then
            return nil
        end
        palette[key] = "#" .. scheme[key]:gsub("^#", "")
    end
    return palette
end

-- fugitive-core's ANSI parser (used by jj-fugitive's log/diff/show views) emits
-- highlight groups named after raw ANSI color names (Red, Green, BoldGreen, ...)
-- that are never otherwise defined, so those views render with no color at all.
-- Point them at the active palette so `:J log`/`:J diff`/`:J show` look right.
local function link_ansi_colors(palette)
    local colors = palette and {
        Black = palette.base03,
        Red = palette.base08,
        Green = palette.base0B,
        Yellow = palette.base0A,
        Blue = palette.base0D,
        Magenta = palette.base0E,
        Cyan = palette.base0C,
        White = palette.base05,
    } or {
        Black = "GruvboxGray",
        Red = "GruvboxRed",
        Green = "GruvboxGreen",
        Yellow = "GruvboxYellow",
        Blue = "GruvboxBlue",
        Magenta = "GruvboxPurple",
        Cyan = "GruvboxAqua",
        White = "GruvboxFg1",
    }
    colors.DarkGray = colors.Black
    for _, name in ipairs({ "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan" }) do
        colors["Light" .. name] = colors[name]
    end

    for name, value in pairs(colors) do
        local spec = palette and { fg = value } or { link = value }
        vim.api.nvim_set_hl(0, name, spec)
        vim.api.nvim_set_hl(0, "Bold" .. name, vim.tbl_extend("force", spec, { bold = true }))
    end
end

-- Some colorschemes (gruvbox included) give SignColumn/FoldColumn a lighter
-- background than the text, so lines with a diff sign show a visibly
-- different gutter color than the text background and than EndOfBuffer's `~`
-- filler. Force the gutter to use the same background as the text itself.
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

-- the palette last applied, so FocusGained only repaints after a real change
local applied

local function apply()
    local palette = read_palette()
    if palette then
        require("mini.base16").setup({ palette = palette })
        vim.g.colors_name = "stylix"
    else
        vim.cmd.colorscheme("gruvbox")
    end
    link_ansi_colors(palette)
    fix_gutter_seam()
    applied = vim.json.encode(palette or {})
end

local group = vim.api.nvim_create_augroup("UserTheme", { clear = true })
-- pick up a theme switched by a rebuild while nvim was already open
vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
        if vim.json.encode(read_palette() or {}) ~= applied then
            apply()
        end
    end,
})

apply()
