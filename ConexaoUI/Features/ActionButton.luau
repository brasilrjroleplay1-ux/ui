--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Shared, theme-aware action and category buttons. All glyphs are local vector primitives.
local tweens = game:GetService("TweenService")
local Buttons = {}
local function bold(font) return Font.new(font.Family, Enum.FontWeight.SemiBold, font.Style) end
local function luminance(c)
    local function linear(v) return v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4 end
    return 0.2126 * linear(c.R) + 0.7152 * linear(c.G) + 0.0722 * linear(c.B)
end
local function contrast(a, b)
    local x, y = luminance(a), luminance(b)
    return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05)
end
local function ink(color)
    local dark, light = Color3.new(0, 0, 0), Color3.new(1, 1, 1)
    return contrast(color, dark) >= contrast(color, light) and dark or light
end
function Buttons.readableColor(preferred, background)
    return contrast(preferred, background) >= 4.5 and preferred or ink(background)
end
function Buttons.new(window, owner, parent, title, symbol, variant, z)
    z = z or 10
    local self = { window = window, owner = owner, shown = true, active = false, hovered = false, pressed = false, variant = variant or "secondary", glyph = {} }
    local function create(class, props) return window:Create(class, props) end
    local function round(node, radius) create("UICorner", { Parent = node, CornerRadius = UDim.new(0, radius) }) end
    self.button = create("TextButton", { Name = title, Parent = parent, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, Size = UDim2.fromOffset(132, 44), ZIndex = z,
    })
    round(self.button, 11)
    self.gradient = create("UIGradient", { Parent = self.button, Rotation = 90 })
    self.stroke = create("UIStroke", { Parent = self.button, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    self.overlay = create("Frame", { Name = "Interaction", Parent = self.button, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = z + 1 })
    round(self.overlay, 11)
    self.content = create("Frame", { Parent = self.button, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), ZIndex = z + 2 })
    self.iconPlate = create("Frame", { Name = symbol, Parent = self.content, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = z + 2 })
    round(self.iconPlate, 6)
    self.icon = create("Frame", { Parent = self.iconPlate, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1, ZIndex = z + 3 })
    local function part(x, y, width, height, angle, outline)
        local node = create("Frame", { Parent = self.icon, Position = UDim2.fromOffset(x, y), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(width, height), Rotation = angle or 0,
            BorderSizePixel = 0, BackgroundTransparency = outline and 1 or 0, ZIndex = z + 3 })
        round(node, outline and 2 or 1)
        if outline then
            local stroke = create("UIStroke", { Parent = node, Thickness = 1.4 })
            table.insert(self.glyph, { node = stroke, color = "Color", alpha = "Transparency" })
        else table.insert(self.glyph, { node = node, color = "BackgroundColor3", alpha = "BackgroundTransparency" }) end
    end
    local function line(x, y, width, angle) part(x, y, width, 1.6, angle) end
    if symbol == "restore" then
        part(9, 10, 11, 10, 0, true);line(4, 5, 7, 0);line(4, 5, 5, -48);line(4, 5, 5, 48)
    elseif symbol == "clear" then
        part(9, 10.5, 10, 10, 0, true);line(9, 4, 14);line(9, 2, 5);line(7, 10.5, 5, 90);line(11, 10.5, 5, 90)
    elseif symbol == "select" then
        line(5, 10, 6, 45);line(10, 8.5, 10, -48);line(9, 14, 5, 45);line(14, 12, 7, -48)
    elseif symbol == "appearance" then
        for index, y in ipairs({ 4, 9, 14 }) do line(9, y, 14);part(index == 2 and 12 or 6, y, 3, 5) end
    elseif symbol == "themes" then
        for _, at in ipairs({ { 5, 5 }, { 13, 5 }, { 5, 13 }, { 13, 13 } }) do part(at[1], at[2], 5, 5, 0, true) end
    elseif symbol == "saving" then
        part(9, 9, 14, 14, 0, true);part(9, 4, 6, 4, 0, true);part(9, 12, 8, 5, 0, true)
    elseif symbol == "graphics" then
        part(9, 9, 15, 10, 0, true);part(9, 9, 4, 4, 0, true)
    elseif symbol == "performance" then
        part(9, 9, 14, 14, 0, true);line(10, 8, 8, -45);part(9, 10, 3, 3)
    else
        part(9, 9, 16, 12, 0, true)
        for _, at in ipairs({ { 5, 7 }, { 9, 7 }, { 13, 7 }, { 5, 11 } }) do part(at[1], at[2], 2, 2) end
        line(11, 11, 5)
    end
    self.label = create("TextLabel", { Parent = self.content, Text = title, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = variant ~= "tab", TextTruncate = Enum.TextTruncate.None, Size = UDim2.fromScale(1, 1), ZIndex = z + 3,
    })
    self.indicator = create("Frame", { Name = "Selected", Parent = self.button, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -4),
        Size = UDim2.new(1, -28, 0, 2), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = z + 4 })
    round(self.indicator, 1)
    self.scale = create("UIScale", { Parent = self.button, Scale = 1 })
    function self:Paint(animate)
        if window.unloaded or owner.closed or not self.button.Parent then return end
        local theme, primary = window.theme, self.variant == "primary"
        local accent, base, content = theme.AccentColor, theme.NeutralButton, theme.ContentColor
        local first, last, foreground, iconColor
        if primary then
            foreground = ink(accent)
            first, last = accent, accent:Lerp(foreground.R == 1 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1), 0.12)
            iconColor = foreground
        else
            first = base:Lerp(accent, self.active and 0.22 or 0.035)
            last = base:Lerp(accent, self.active and 0.09 or 0.015)
            foreground = contrast(content, first) >= 4.5 and contrast(content, last) >= 4.5 and content or ink(first)
            iconColor = contrast(accent, first) >= 3 and accent or content
        end
        self.gradient.Color = ColorSequence.new(first, last)
        self.label.TextColor3, self.label.FontFace = foreground, bold(theme.TitleFont)
        self.stroke.Color = (primary or self.active) and accent or theme.SurfaceStroke
        self.iconPlate.BackgroundColor3 = primary and foreground or accent
        self.overlay.BackgroundColor3 = primary and (foreground.R == 1 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)) or content
        self.indicator.BackgroundColor3 = accent
        window:_reveal(self.button, { BackgroundTransparency = self.shown and 0 or 1 }, animate)
        window:_reveal(self.label, { TextTransparency = self.shown and 0 or 1 }, animate)
        window:_reveal(self.stroke, { Transparency = self.shown and ((primary or self.active) and 0.15 or (self.hovered and 0.3 or 0.65)) or 1 }, animate)
        window:_reveal(self.iconPlate, { BackgroundTransparency = self.shown and (primary and 0.92 or (self.active and 0.84 or 0.92)) or 1 }, animate)
        window:_reveal(self.overlay, { BackgroundTransparency = self.shown and (self.pressed and 0.86 or (self.hovered and 0.94 or 1)) or 1 }, animate)
        window:_reveal(self.indicator, { BackgroundTransparency = self.shown and self.active and 0 or 1 }, animate)
        for _, glyph in ipairs(self.glyph) do
            glyph.node[glyph.color] = iconColor
            window:_reveal(glyph.node, { [glyph.alpha] = self.shown and 0 or 1 }, animate)
        end
        local target = self.shown and self.pressed and 0.98 or 1
        if self.scaleTween then self.scaleTween:Cancel() self.scaleTween = nil end
        if animate then
            self.scaleTween = tweens:Create(self.scale, TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = target })
            self.scaleTween:Play()
        else self.scale.Scale = target end
    end
    function self:Layout(width, height)
        local tab = self.variant == "tab"
        local plate, gap, padding = tab and 24 or 20, tab and 8 or 7, tab and 12 or 6
        local desired = (utf8.len(title) or #title) * 14 * 0.58 + 4 + plate + gap
        local extent = tab and math.max(1, width - padding * 2) or math.min(desired, math.max(1, width - padding * 2))
        self.content.Position, self.content.Size = UDim2.fromOffset(tab and padding or (width - extent) / 2, 0), UDim2.fromOffset(extent, height)
        self.iconPlate.Position, self.iconPlate.Size = UDim2.new(0, 0, 0.5, 0), UDim2.fromOffset(plate, plate)
        self.label.Position, self.label.Size = UDim2.fromOffset(plate + gap, 4), UDim2.fromOffset(math.max(1, extent - plate - gap), math.max(1, height - 8))
    end
    function self:SetShown(shown, animate)
        self.shown = shown
        if not shown then self.hovered, self.pressed = false, false end
        self:Paint(animate)
    end
    local function connect(signal, callback) window:ConnectFor(owner, signal, callback) end
    connect(self.button.MouseEnter, function() self.hovered = true self:Paint(true) end)
    connect(self.button.MouseLeave, function() self.hovered, self.pressed = false, false self:Paint(true) end)
    connect(self.button.SelectionGained, function() self.hovered = true self:Paint(true) end)
    connect(self.button.SelectionLost, function() self.hovered, self.pressed = false, false self:Paint(true) end)
    connect(self.button.InputBegan, function(key)
        if key.UserInputType == Enum.UserInputType.MouseButton1 or key.UserInputType == Enum.UserInputType.Touch then self.pressed = true self:Paint(true) end
    end)
    connect(self.button.InputEnded, function(key)
        if key.UserInputType == Enum.UserInputType.MouseButton1 or key.UserInputType == Enum.UserInputType.Touch then self.pressed = false self:Paint(true) end
    end)
    connect(self.button.Destroying, function() if self.scaleTween then self.scaleTween:Cancel() end end)
    self:Layout(132, 44)
    self:Paint(false)
    return self
end
return Buttons
