--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Geometric identifiers drawn with GuiObjects: sharp at any UI scale, no icon downloads.
local BrandIcon = {}
local Assets = require(script.Parent.BrandAssets)
local Catalog = require(script.Parent.ExecutorCatalog)
local custom = {}

function BrandIcon.register(name, icon, aliases)
    assert(type(name) == "string" and name ~= "", "Executor name is required")
    assert((type(icon) == "string" and icon ~= "") or (type(icon) == "number" and icon > 0 and icon < math.huge), "Use an image asset ID or a local asset URI")
    local entry = { id = Catalog.key(name), image = icon }
    assert(entry.id ~= "", "Use a name containing letters or numbers")
    custom[Catalog.key(name)] = entry
    for _, alias in ipairs(aliases or {}) do custom[Catalog.key(alias)] = entry end
    return entry
end

function BrandIcon.kind(name)
    name = string.lower(tostring(name or ""))
    if Catalog.key(name) == "robloxstudio" or name == "studio" then return "studio" end
    if name == "roblox" then return "roblox" end
    local entry = custom[Catalog.key(name)] or Catalog.find(name)
    if entry then return entry.id end
    if name == "settings" or name == "themes" or name == "copy" or name == "clock" then return name end
    return "terminal"
end

function BrandIcon.new(window, parent, name, props, track, white)
    local kind = BrandIcon.kind(name)
    local p = { Name = kind .. "Icon", Parent = parent, BackgroundTransparency = 1, Size = UDim2.fromOffset(20, 20), ZIndex = 7 }
    for key, value in pairs(props or {}) do p[key] = value end
    local root = window:Create("Frame", p)
    local parts = {}
    local function block(host, position, size, rotation)
        local node = window:Create("Frame", {
            Parent = host, Name = "Mark", Position = position, Size = size, Rotation = rotation or 0,
            BorderSizePixel = 0, BackgroundTransparency = track and 1 or 0, ZIndex = root.ZIndex,
            BackgroundColor3 = white and Color3.new(1, 1, 1) or window.theme.ContentColor,
        }, not white and { BackgroundColor3 = "ContentColor" } or nil)
        if track then track(node, "BackgroundTransparency", 0) end
        table.insert(parts, node)
        return node
    end
    local function line(x1, y1, x2, y2, weight)
        local dx, dy = x2 - x1, y2 - y1
        local node = block(root, UDim2.fromScale((x1 + x2) / 48, (y1 + y2) / 48), UDim2.fromScale(math.sqrt(dx * dx + dy * dy) / 24, (weight or 2.4) / 24), math.deg(math.atan2(dy, dx)))
        node.AnchorPoint = Vector2.new(0.5, 0.5)
    end
    local override = custom[Catalog.key(name)]
    local uri = override and override.image or Assets.get(kind)
    if uri then
        local logo = window:Create("ImageLabel", {
            Parent = root, Name = "ExecutorLogo", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            ImageTransparency = track and 1 or 0, ScaleType = Enum.ScaleType.Fit,
            ResampleMode = Enum.ResamplerMode.Default, ZIndex = root.ZIndex,
        })
        -- This URI comes from the local asset API, including when secure mode is active.
        logo.Image = type(uri) == "number" and ("rbxassetid://" .. uri) or uri
        if track then track(logo, "ImageTransparency", 0) end
        return { root = root, parts = { logo }, kind = kind, artwork = true }
    elseif kind == "delta" then
        line(12, 3, 22, 21, 2.8)
        line(22, 21, 2, 21, 2.8)
        line(2, 21, 12, 3, 2.8)
    elseif kind == "roblox" or kind == "studio" then
        local square = window:Create("Frame", {
            Parent = root, Name = "TiltedSquare", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(kind == "studio" and 0.68 or 0.72, kind == "studio" and 0.68 or 0.72), Rotation = kind == "studio" and 45 or -20, ZIndex = root.ZIndex,
        })
        local weight = kind == "studio" and 0.18 or 0.28
        block(square, UDim2.fromScale(0, 0), UDim2.fromScale(1, weight))
        block(square, UDim2.fromScale(0, 1 - weight), UDim2.fromScale(1, weight))
        block(square, UDim2.fromScale(0, weight), UDim2.fromScale(weight, 1 - weight * 2))
        block(square, UDim2.fromScale(1 - weight, weight), UDim2.fromScale(weight, 1 - weight * 2))
    elseif kind == "copy" then
        line(8, 3, 21, 3) line(21, 3, 21, 16) line(21, 16, 18, 16)
        line(3, 8, 16, 8) line(16, 8, 16, 21) line(16, 21, 3, 21) line(3, 21, 3, 8)
    elseif kind == "themes" then
        line(4, 5, 20, 5, 3) line(4, 12, 16, 12, 3) line(4, 19, 12, 19, 3)
    elseif kind == "settings" then
        line(4, 6, 20, 6) line(4, 12, 20, 12) line(4, 18, 20, 18)
        line(8, 3, 8, 9, 3) line(16, 9, 16, 15, 3) line(10, 15, 10, 21, 3)
    elseif kind ~= "terminal" then
        local monogram = window:Create("TextLabel", {
            Parent = root, Text = string.upper(string.sub(tostring(name), 1, 1)), Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1, TextScaled = true, TextTransparency = track and 1 or 0,
            TextColor3 = white and Color3.new(1, 1, 1) or window.theme.ContentColor, ZIndex = root.ZIndex,
        }, { FontFace = "TitleFont" })
        if track then track(monogram, "TextTransparency", 0) end
        table.insert(parts, monogram)
    else
        line(3, 6, 9, 12)
        line(9, 12, 3, 18)
        line(13, 18, 21, 18)
    end
    return { root = root, parts = parts, kind = kind }
end

return BrandIcon
