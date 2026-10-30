--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- The same vector signature is used in the launcher and window header.
local tweenService = game:GetService("TweenService")
local Brand = {}

function Brand.new(create, parent, size, theme)
    theme = theme or {}
    local accent = theme.AccentColor or Color3.fromRGB(154, 104, 255)
    local gradient = theme.SliderProgress or ColorSequence.new(accent, Color3.fromRGB(75, 173, 255))
    local function ink(color)
        return color.R * 0.299 + color.G * 0.587 + color.B * 0.114 > 0.52 and Color3.fromRGB(18, 19, 28) or Color3.new(1, 1, 1)
    end
    local self = { targets = {}, links = {} }
    local function track(node, property, value) table.insert(self.targets, { node = node, property = property, value = value }) end
    self.root = create("Frame", { Name = "ConexaoMark", Parent = parent, Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, ZIndex = 5 })
    self.plate = create("Frame", {
        Name = "SignaturePlate", Parent = self.root, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    })
    create("UICorner", { Parent = self.plate, CornerRadius = UDim.new(0.28, 0) })
    self.gradient = create("UIGradient", { Parent = self.plate, Rotation = 35, Color = gradient }, { Color = "SliderProgress" })
    local rim = create("UIStroke", { Parent = self.plate, Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 1 })
    track(self.plate, "BackgroundTransparency", 0)
    track(rim, "Transparency", 0.72)
    for index, position in ipairs({ Vector2.new(0.37, 0.41), Vector2.new(0.63, 0.59) }) do
        local link = create("Frame", {
            Name = "Link" .. index, Parent = self.plate, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(position.X, position.Y),
            Size = UDim2.fromScale(0.38, 0.53), Rotation = -32, BackgroundTransparency = 1, ZIndex = 6,
        })
        create("UICorner", { Parent = link, CornerRadius = UDim.new(0.4, 0) })
        local stroke = create("UIStroke", { Parent = link, Thickness = math.max(2, size * 0.055), Color = ink(accent), Transparency = 1 }, { Color = { "AccentColor", ink } })
        track(stroke, "Transparency", 0)
        table.insert(self.links, { node = link, position = link.Position })
    end
    function self:SetShown(shown, info, assemble)
        for _, target in ipairs(self.targets) do
            local props = { [target.property] = shown and target.value or 1 }
            if info then tweenService:Create(target.node, info, props):Play()
            else target.node[target.property] = props[target.property] end
        end
        if shown and assemble then
            for index, link in ipairs(self.links) do
                local direction = index == 1 and -1 or 1
                link.node.Position = link.position + UDim2.fromScale(direction * 0.14, -direction * 0.1)
                link.node.Rotation = -32 + direction * 18
                tweenService:Create(link.node, info or TweenInfo.new(0.4), { Position = link.position, Rotation = -32 }):Play()
            end
        end
    end
    return self
end

return Brand
