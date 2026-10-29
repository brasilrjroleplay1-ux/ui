--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local native = script.Parent.Parent.Gen2.themes
local Themes = {}
local rgb = Color3.fromRGB
local presets = {
    { "conexao", "Conexão", "Violeta elétrico", rgb(155, 72, 255), rgb(71, 112, 255), rgb(17, 13, 29), rgb(38, 23, 61) },
    { "aurora", "Aurora", "Verde e turquesa", rgb(24, 225, 177), rgb(28, 147, 239), rgb(8, 21, 25), rgb(15, 46, 49) },
    { "oceano", "Oceano", "Azul e ciano", rgb(35, 158, 255), rgb(39, 225, 244), rgb(10, 17, 32), rgb(18, 37, 65) },
    { "crepusculo", "Crepúsculo", "Coral e violeta", rgb(255, 130, 83), rgb(192, 73, 244), rgb(26, 14, 27), rgb(55, 27, 45) },
    { "sakura", "Sakura", "Rosa e lavanda", rgb(248, 100, 179), rgb(177, 118, 255), rgb(28, 14, 28), rgb(56, 26, 49) },
    { "onyx", "Ônix", "Dourado sobre carvão", rgb(244, 191, 77), rgb(255, 137, 67), rgb(17, 18, 22), rgb(38, 36, 32) },
}
Themes.catalog = {}
local named = {}
for _, p in ipairs(presets) do
    local theme = table.clone(require(native["default"]))
    local accent, secondary, base, raised = p[4], p[5], p[6], p[7]
    theme.WindowColor = ColorSequence.new(base, raised)
    theme.ShadowColor = base:Lerp(Color3.new(0, 0, 0), 0.5)
    theme.ElementGradient = ColorSequence.new(base:Lerp(raised, 0.5), raised)
    theme.ElementStroke = raised:Lerp(accent, 0.3)
    theme.ElementStrokeGradient = ColorSequence.new(raised:Lerp(accent, 0.45), raised:Lerp(secondary, 0.25))
    theme.ElementStrokeHover = accent
    theme.TabBackground = ColorSequence.new(accent:Lerp(base, 0.35), secondary:Lerp(base, 0.6))
    theme.TabStroke = ColorSequence.new(accent, secondary)
    theme.SliderProgress = ColorSequence.new(accent, secondary)
    theme.SliderBackground = raised:Lerp(accent, 0.1)
    theme.SliderBackgroundHover = raised:Lerp(accent, 0.25)
    theme.AccentColor, theme.AccentStroke, theme.DropdownHighlight = accent, accent:Lerp(Color3.new(1, 1, 1), 0.35), accent
    theme.StatBackground, theme.NeutralButton = raised, raised
    theme.NeutralButtonHover, theme.NeutralButtonStroke = raised:Lerp(accent, 0.25), accent
    theme.ContentColor, theme.TitlingColor = rgb(248, 247, 255), rgb(255, 255, 255)
    theme.ToggleKnobOff, theme.ToggleKnobOffTransparency = rgb(218, 220, 237), 0.12
    theme.FieldBackground, theme.FieldGlow = accent, accent
    theme.FieldTransparency, theme.PlaceholderColor = 0.91, rgb(181, 184, 207)
    theme.SurfaceStroke = accent:Lerp(Color3.new(1, 1, 1), 0.45)
    local entry = { id = p[1], name = p[2], description = p[3], theme = theme }
    named[p[1]] = entry
    table.insert(Themes.catalog, entry)
end
for _, id in ipairs({ "default", "amethyst", "cobalt", "ember", "frost", "rose" }) do
    local theme = table.clone(require(native["default"]))
    for key, value in pairs(require(native[id])) do theme[key] = value end
    local entry = { id = id, name = id:sub(1, 1):upper() .. id:sub(2), description = "Gen2 original", theme = theme }
    named[id] = entry
    table.insert(Themes.catalog, entry)
end

function Themes.resolve(id)
    local entry = type(id) == "string" and named[id:lower()]
    return entry and table.clone(entry.theme) or nil
end

function Themes.entry(id) return type(id) == "string" and named[id:lower()] or nil end

return Themes
