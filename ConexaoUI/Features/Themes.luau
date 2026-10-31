--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local native = script.Parent.Parent.Gen2.themes
local Themes = {}
local hex = Color3.fromHex

-- Individually authored palettes: no random colors, hue rotation or renamed copies.
-- id, name, description, family, accent, secondary, window, raised surface
local presets = {
    { "conexao", "Conexão", "Violeta elétrico e azul", "Assinatura", "9B48FF", "4770FF", "110D1D", "26173D" },
    { "aurora", "Aurora", "Verde luminoso e turquesa", "Assinatura", "18E1B1", "1C93EF", "081519", "0F2E31" },
    { "oceano", "Oceano", "Azul vivo e ciano", "Assinatura", "239EFF", "27E1F4", "0A1120", "122541" },
    { "crepusculo", "Crepúsculo", "Coral e violeta ao anoitecer", "Assinatura", "FF8253", "C049F4", "1A0E1B", "371B2D" },
    { "sakura", "Sakura", "Rosa intenso e lavanda", "Assinatura", "F864B3", "B176FF", "1C0E1C", "381A31" },
    { "onyx", "Ônix", "Dourado e âmbar sobre carvão", "Assinatura", "F4BF4D", "FF8943", "111216", "262420" },

    { "cyberpunk", "Cyberpunk", "Amarelo ácido e magenta", "Neon", "FFE747", "FF29B9", "100D20", "281335" },
    { "laser", "Laser", "Lima elétrico e azul-gelo", "Neon", "BDFF3B", "31DFFF", "071815", "14312A" },
    { "synthwave", "Synthwave", "Pink e laranja sobre ameixa", "Neon", "FF42A6", "FFAD4A", "250B2C", "471640" },
    { "arcade", "Arcade", "Azul elétrico e chiclete", "Neon", "5271FF", "FF75DC", "080C27", "17204A" },
    { "plasma", "Plasma", "Orquídea e verde ácido", "Neon", "D97BFF", "D3FF47", "1D0B2A", "36184A" },
    { "holografico", "Holográfico", "Ciano perolado e lilás", "Neon", "8DF9FF", "C6ADFF", "132334", "294057" },
    { "toxico", "Tóxico", "Chartreuse e verde radioativo", "Neon", "D8F537", "4EF48A", "141B08", "2D3712" },
    { "infravermelho", "Infravermelho", "Escarlate e tangerina", "Neon", "FF4A62", "FF9437", "210B10", "421720" },
    { "ultravioleta", "Ultravioleta", "Íris e turquesa em azul-noite", "Neon", "AE99FF", "45F4CA", "11102B", "24224F" },
    { "glitch", "Glitch", "Branco elétrico e vermelho", "Neon", "E9F6FF", "FF365C", "090D10", "22282E" },

    { "floresta", "Floresta", "Samambaia e jade profundo", "Natureza", "67D17D", "24B89E", "0B1911", "1C3425" },
    { "mangue", "Mangue", "Verde cítrico e ocre", "Natureza", "A7CE58", "D6A750", "191D0F", "353A20" },
    { "coral", "Coral", "Salmão e azul de recife", "Natureza", "FF8C7C", "54C7D4", "112128", "203D44" },
    { "bambu", "Bambu", "Amarelo-lima e verde folha", "Natureza", "E3D56B", "7ACD62", "182015", "303D27" },
    { "lavanda", "Lavanda", "Malva e sálvia sobre berinjela", "Natureza", "C4A0E9", "A5C7B6", "211B2B", "3D3149" },
    { "girassol", "Girassol", "Ouro solar e terracota", "Natureza", "FFD146", "DE7951", "241B0E", "47301A" },
    { "savana", "Savana", "Âmbar e oliva em terra escura", "Natureza", "DAB276", "A5B959", "242219", "44402B" },
    { "amazonia", "Amazônia", "Esmeralda e azul de rio", "Natureza", "36DB96", "4DABF5", "081F20", "123A38" },
    { "cerejeira", "Cerejeira", "Carmim e pêssego sobre vinho", "Natureza", "F27991", "F4C5A1", "2B111B", "4B2531" },
    { "musgo", "Musgo", "Verde mineral e eucalipto", "Natureza", "ACC58B", "79B6A4", "1B2420", "35463B" },

    { "eclipse", "Eclipse", "Cobre e índigo sobre grafite", "Cósmicos", "EEA263", "8D82F8", "12121C", "2B2737" },
    { "boreal", "Boreal", "Menta polar e azul intenso", "Cósmicos", "9AF2CF", "758FFF", "0E1D2D", "1B3548" },
    { "marte", "Marte", "Ferrugem e rosa sobre argila", "Cósmicos", "F39770", "E6A1AB", "291510", "4C2C25" },
    { "saturno", "Saturno", "Champanhe e lavanda cósmica", "Cósmicos", "EAC78C", "BD9DDC", "221A24", "413044" },
    { "nebula", "Nébula", "Pervinca e pêssego estelar", "Cósmicos", "A6AEFF", "FFB8A6", "21182F", "3F3053" },
    { "supernova", "Supernova", "Marfim e laranja sobre amora", "Cósmicos", "FFF0CB", "FF9D44", "2A102B", "521D43" },
    { "abissal", "Abissal", "Turquesa e azul nas profundezas", "Cósmicos", "42DACC", "326EF0", "050F20", "0D2440" },
    { "tempestade", "Tempestade", "Prata e lilás sobre ardósia", "Cósmicos", "C3D4E7", "B8A7E3", "202733", "3C4758" },
    { "lua", "Lua", "Azul lunar e branco frio", "Cósmicos", "B1CEF5", "EEF3FD", "121923", "2B3445" },
    { "solsticio", "Solstício", "Caqui e ouro sobre noite azul", "Cósmicos", "FF9C68", "F7D76F", "171A2A", "362B36" },

    { "porcelana", "Porcelana", "Azul real e ouro sobre marfim", "Claros", "2858AC", "B68932", "F5F2EB", "FFFDF7" },
    { "matcha", "Matcha", "Verde chá e oliva sobre sálvia", "Claros", "38734C", "7B8633", "E8EFDF", "F6FAED" },
    { "algodao", "Algodão", "Framboesa e ameixa sobre rosa", "Claros", "AE3F70", "79519F", "F8EAF1", "FFF7FB" },
    { "ceu", "Céu", "Azul cerúleo e índigo no branco", "Claros", "2069B0", "5657B8", "E6F1FC", "F7FBFF" },
    { "pessego", "Pêssego", "Laranja queimado e terracota", "Claros", "B7552D", "B65F72", "FBEDE1", "FFF8EE" },
    { "lilas", "Lilás", "Violeta e uva sobre névoa lilás", "Claros", "7345AD", "9B527F", "EFE8F8", "FBF7FF" },
    { "areia", "Areia", "Canela e petróleo sobre linho", "Claros", "98652C", "397B7D", "EFE7D5", "FBF6E8" },
    { "menta", "Menta", "Verde-petróleo e azul suave", "Claros", "207C71", "546AAB", "E2F4ED", "F3FFF9" },
    { "geleira", "Geleira", "Azul-aço e ardósia sobre gelo", "Claros", "42678A", "687F93", "E8EDF2", "F8FAFC" },
    { "perola", "Pérola", "Bordô e bronze sobre madrepérola", "Claros", "884B60", "9F8045", "F2EAE8", "FFFAF6" },

    { "rubi", "Rubi", "Carmesim e ouro em vinho negro", "Minerais", "EC536F", "E8BA68", "1E0B18", "3D1931" },
    { "safira", "Safira", "Azul safira e champanhe", "Minerais", "6B9AFF", "EDD6A7", "0C1430", "182950" },
    { "esmeralda", "Esmeralda", "Verde joia e ciano em petróleo", "Minerais", "55E5AD", "74D7EB", "092326", "174248" },
    { "fluorita", "Fluorita", "Ameixa e verde cristalino", "Minerais", "D693EB", "84E2B1", "252034", "433951" },
    { "topazio", "Topázio", "Âmbar tostado e azul mineral", "Minerais", "F7A449", "7E9BD7", "241A17", "483327" },
    { "obsidiana", "Obsidiana", "Prata e gelo sobre preto puro", "Minerais", "D7DAE3", "93AFBA", "050608", "1B1E24" },
    { "cobre", "Cobre", "Cobre polido e verdete", "Minerais", "E5A078", "6BC0B6", "221713", "422E25" },
    { "opala", "Opala", "Azul leitoso e rosa opalescente", "Minerais", "A6E3ED", "F1B9D0", "263043", "43536A" },
}

Themes.catalog = {}
Themes.groups = { "Assinatura", "Neon", "Natureza", "Cósmicos", "Claros", "Minerais", "Clássicos" }
local named = {}
local white, black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
local function luminance(color)
    local function linear(c) return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4 end
    return 0.2126 * linear(color.R) + 0.7152 * linear(color.G) + 0.0722 * linear(color.B)
end
local function contrast(a, b)
    local x, y = luminance(a), luminance(b)
    return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05)
end

-- Shared depth and typography roles. Every palette retains its own accent pair and tint.
local function finish(theme)
    local points = theme.WindowColor.Keypoints
    local original, raised = points[1].Value, theme.StatBackground
    local accent = theme.AccentColor
    local slider = theme.SliderProgress.Keypoints
    local secondary = slider[#slider].Value
    local light = luminance(original) > 0.5
    local base = light and original or original:Lerp(hex("0D1018"), 0.6)
    local surface = light and raised or raised:Lerp(hex("242936"), 0.45)
    local ink = light and hex("202633") or hex("F4F6FC")
    theme.WindowColor = ColorSequence.new({ ColorSequenceKeypoint.new(0, base),
        ColorSequenceKeypoint.new(0.55, base:Lerp(surface, 0.18)), ColorSequenceKeypoint.new(1, base:Lerp(secondary, light and 0.035 or 0.06)) })
    theme.ElementGradient = ColorSequence.new(surface:Lerp(accent, light and 0.025 or 0.055), surface:Lerp(base, 0.16))
    theme.ButtonGradient = ColorSequence.new(surface:Lerp(accent, light and 0.07 or 0.14), surface:Lerp(secondary, light and 0.035 or 0.07))
    theme.HeaderGradient = ColorSequence.new(base:Lerp(surface, 0.32), base:Lerp(accent, light and 0.055 or 0.09))
    theme.RailGradient = ColorSequence.new(base:Lerp(surface, 0.2), base)
    theme.HeroGradient = ColorSequence.new(surface:Lerp(accent, light and 0.12 or 0.24), surface:Lerp(secondary, light and 0.08 or 0.16))
    theme.ContentColor, theme.TitlingColor, theme.ElementTextHoverColor, theme.TabColor = ink, ink, ink, ink
    local muted = ink:Lerp(surface, light and 0.25 or 0.28)
    if contrast(muted, surface) < 4.5 then muted = ink end
    theme.MutedContent, theme.PlaceholderColor = muted, muted
    theme.StatBackground, theme.NeutralButton = surface, surface
    theme.NeutralButtonHover, theme.NeutralButtonStroke = surface:Lerp(accent, 0.18), surface:Lerp(ink, 0.25)
    theme.SurfaceStroke = surface:Lerp(ink, light and 0.24 or 0.3)
    theme.ElementStroke, theme.ElementStrokeHover = surface:Lerp(ink, 0.18), accent
    theme.ElementStrokeTransparency, theme.ElementStrokeHoverTransparency = 0.4, 0.12
    theme.ElementStrokeGradient = ColorSequence.new(surface:Lerp(accent, 0.3), surface:Lerp(secondary, 0.2))
    theme.ElementCornerRadius = UDim.new(0, 12)
    theme.TabBackground = ColorSequence.new(surface:Lerp(accent, light and 0.12 or 0.23), surface:Lerp(secondary, light and 0.08 or 0.12))
    theme.TabStroke = ColorSequence.new(accent, secondary)
    theme.SliderBackground, theme.SliderBackgroundHover = surface:Lerp(ink, light and 0.12 or 0.1), surface:Lerp(accent, 0.2)
    theme.SliderHandle = light and hex("2D3648") or white
    theme.ToggleTrack = surface:Lerp(ink, light and 0.14 or 0.1)
    theme.ToggleTrackTransparency = 0
    theme.ToggleKnobOff, theme.ToggleKnobOffTransparency = ink:Lerp(surface, 0.32), 0
    theme.FieldBackground, theme.FieldTransparency, theme.FieldGlow = surface:Lerp(accent, light and 0.06 or 0.1), 0, accent
    theme.AccentGlow = light and 0.88 or 0.65
    return theme
end

local accents = { ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["é"] = "e", ["ê"] = "e", ["í"] = "i", ["ó"] = "o", ["ô"] = "o", ["õ"] = "o", ["ú"] = "u", ["ç"] = "c", ["Á"] = "a", ["À"] = "a", ["Â"] = "a", ["Ã"] = "a", ["É"] = "e", ["Ê"] = "e", ["Í"] = "i", ["Ó"] = "o", ["Ô"] = "o", ["Õ"] = "o", ["Ú"] = "u", ["Ç"] = "c" }
function Themes.normalize(value)
    value = string.lower(value)
    for accented, plain in pairs(accents) do value = string.gsub(value, accented, plain) end
    return value
end

local function register(entry)
    assert(not named[entry.id], "Repeated theme id: " .. entry.id)
    entry.theme = finish(entry.theme)
    entry.search = Themes.normalize(entry.id .. " " .. entry.name .. " " .. entry.description .. " " .. entry.group)
    named[entry.id] = entry
    table.insert(Themes.catalog, entry)
end

for _, p in ipairs(presets) do
    local theme = table.clone(require(native["default"]))
    local accent, secondary, base, raised = hex(p[5]), hex(p[6]), hex(p[7]), hex(p[8])
    local light = luminance(base) > 0.5
    local ink = light and base:Lerp(black, 0.88) or base:Lerp(white, 0.94)
    theme.WindowColor = ColorSequence.new(base, raised)
    theme.ShadowColor = light and base:Lerp(black, 0.45) or base:Lerp(black, 0.5)
    theme.ElementGradient = ColorSequence.new(base:Lerp(raised, 0.55), raised)
    theme.ElementStroke = raised:Lerp(accent, light and 0.2 or 0.3)
    theme.ElementStrokeGradient = ColorSequence.new(raised:Lerp(accent, 0.35), raised:Lerp(secondary, 0.25))
    theme.ElementStrokeHover = accent
    theme.ElementStrokeTransparency, theme.ElementStrokeHoverTransparency = 0.15, 0
    theme.TabBackground = light and ColorSequence.new(accent:Lerp(raised, 0.84), secondary:Lerp(raised, 0.86))
        or ColorSequence.new(accent:Lerp(base, 0.72), secondary:Lerp(base, 0.76))
    theme.TabStroke = ColorSequence.new(accent, secondary)
    theme.TabColor, theme.ActionColor = ink, ink
    theme.SliderProgress = ColorSequence.new(accent, secondary)
    theme.SliderBackground = raised:Lerp(accent, 0.12)
    theme.SliderBackgroundHover = raised:Lerp(accent, 0.25)
    theme.SliderStroke, theme.SliderHandle = raised:Lerp(ink, 0.35), ink
    theme.AccentColor, theme.AccentStroke, theme.DropdownHighlight = accent, accent:Lerp(ink, 0.3), accent
    theme.AccentGlow, theme.DarkToggleOverlay = light and 0.85 or 0.4, not light
    theme.StatBackground, theme.NeutralButton = raised, raised
    theme.NeutralButtonHover, theme.NeutralButtonStroke = raised:Lerp(accent, light and 0.12 or 0.25), raised:Lerp(accent, 0.55)
    theme.ContentColor, theme.TitlingColor, theme.ElementTextHoverColor = ink, ink, ink
    theme.ToggleTrack = raised:Lerp(ink, light and 0.2 or 0.06)
    theme.ToggleTrackTransparency = light and 0 or 0.15
    theme.ToggleKnobOff, theme.ToggleKnobOffTransparency = raised:Lerp(ink, 0.65), 0.08
    theme.FieldBackground, theme.FieldGlow = light and raised:Lerp(accent, 0.08) or accent, accent
    theme.FieldTransparency = light and 0 or 0.91
    theme.PlaceholderColor = raised:Lerp(ink, light and 0.7 or 0.62)
    theme.SurfaceStroke = raised:Lerp(ink, 0.45)
    register({ id = p[1], name = p[2], description = p[3], group = p[4], kind = light and "light" or "dark", theme = theme })
end

for _, p in ipairs({
    { "default", "Grafite", "Carvão neutro e verde discreto" },
    { "amethyst", "Ametista", "Violeta clássico em fundo escuro" },
    { "cobalt", "Cobalto", "Azul clássico e aço" },
    { "ember", "Brasa", "Laranja clássico e cinzas quentes" },
    { "frost", "Geada", "Branco frio e ciano clássico" },
    { "rose", "Rosa", "Rosa clássico e tons de vinho" },
}) do
    local theme = table.clone(require(native["default"]))
    for key, value in pairs(require(native[p[1]])) do theme[key] = value end
    register({ id = p[1], name = p[2], description = p[3], group = "Clássicos", kind = p[1] == "frost" and "light" or "dark", theme = theme })
end

function Themes.matches(entry, query, group)
    return (not group or group == "Todos" or entry.group == group)
        and string.find(entry.search, Themes.normalize(query or ""), 1, true) ~= nil
end

function Themes.resolve(id)
    local entry = type(id) == "string" and named[id:lower()]
    return entry and table.clone(entry.theme) or nil
end

function Themes.entry(id) return type(id) == "string" and named[id:lower()] or nil end

return Themes
