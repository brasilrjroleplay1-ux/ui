--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Shared, tracked overlay. All geometry is in the same coordinate space as the window.
local Surface = {}
Surface.__index = Surface
local input = game:GetService("UserInputService")

function Surface.round(window, parent, radius)
    return window:Create("UICorner", { Parent = parent, CornerRadius = UDim.new(0, radius or 12) })
end

function Surface.label(window, parent, text, props)
    local p = {
        Parent = parent, Text = text, BackgroundTransparency = 1, BorderSizePixel = 0,
        TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 22), ZIndex = 4014,
    }
    for key, value in pairs(props or {}) do p[key] = value end
    return window:Create("TextLabel", p, { TextColor3 = "ContentColor", FontFace = "Font" })
end

function Surface.button(window, parent, text, props, primary)
    local p = {
        Parent = parent, Text = text, BorderSizePixel = 0, AutoButtonColor = false,
        TextSize = 14, TextWrapped = true, Size = UDim2.new(1, 0, 0, 42), ZIndex = 4015,
    }
    for key, value in pairs(props or {}) do p[key] = value end
    local button = window:Create("TextButton", p, {
        BackgroundColor3 = primary and "AccentColor" or "NeutralButton",
        TextColor3 = primary and { "AccentColor", function(color)
            return (color.R * 0.299 + color.G * 0.587 + color.B * 0.114) > 0.58 and Color3.fromRGB(12, 17, 25) or Color3.new(1, 1, 1)
        end } or "ContentColor", FontFace = "Font",
    })
    Surface.round(window, button, 11)
    window:Create("UIStroke", { Parent = button, Thickness = 1, Transparency = 0.55 }, {
        Color = primary and "AccentStroke" or "NeutralButtonStroke",
    })
    return button
end

function Surface.new(window, title, subtitle, options)
    if window._conexaoModal then window._conexaoModal:Close() end
    options = options or {}
    local self = setmetatable({ window = window, connections = {}, closed = false }, Surface)
    window._conexaoModal = self
    self.root = window:Create("Frame", {
        Name = "ConexaoOverlay", Parent = window.screenGui, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), ZIndex = 4000,
    })
    self.scrim = window:Create("TextButton", {
        Parent = self.root, Size = UDim2.fromScale(1, 1), Text = "", AutoButtonColor = false,
        BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4,
        BorderSizePixel = 0, Active = true, Modal = true, ZIndex = 4001,
    })
    self.panel = window:Create("Frame", {
        Name = "Panel", Parent = self.root, AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Active = true, ZIndex = 4010,
    })
    -- A blank area inside the panel must not click through to the outside-dismiss target.
    self.shield = window:Create("TextButton", {
        Parent = self.panel, Size = UDim2.fromScale(1, 1), Text = "", BackgroundTransparency = 1,
        BorderSizePixel = 0, AutoButtonColor = false, Active = true, ZIndex = 4011,
    })
    Surface.round(window, self.panel, 18)
    window:Create("UIGradient", { Parent = self.panel, Rotation = 35 }, { Color = "WindowColor" })
    window:Create("UIStroke", { Parent = self.panel, Thickness = 1.5, Transparency = 0.2 }, { Color = "AccentStroke" })
    self.title = Surface.label(window, self.panel, title, {
        Position = UDim2.fromOffset(20, 18), Size = UDim2.new(1, -82, 0, 25), TextSize = 21,
    })
    self.subtitle = Surface.label(window, self.panel, subtitle or "", {
        Position = UDim2.fromOffset(20, 47), Size = UDim2.new(1, -82, 0, 26), TextSize = 12, TextTransparency = 0.25,
    })
    self.closeButton = Surface.button(window, self.panel, "×", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16), Size = UDim2.fromOffset(36, 36), TextSize = 24,
    })
    self.content = window:Create("Frame", {
        Parent = self.panel, BackgroundTransparency = 1, Position = UDim2.fromOffset(18, 88),
        Size = UDim2.new(1, -36, 1, options.footer and -164 or -108), ZIndex = 4011,
    })
    if options.footer then
        self.footer = window:Create("Frame", {
            Parent = self.panel, BackgroundTransparency = 1, Position = UDim2.new(0, 18, 1, -60),
            Size = UDim2.new(1, -36, 0, 42), ZIndex = 4011,
        })
    end
    function self:Layout()
        if self.closed then return end
        local view = self.root.AbsoluteSize
        if view.X <= 0 or view.Y <= 0 then
            local camera = workspace.CurrentCamera
            view = camera and camera.ViewportSize or Vector2.new(800, 600)
        end
        local at, size = window.main.AbsolutePosition, window.main.AbsoluteSize
        if size.X <= 0 or size.Y <= 0 then size = Vector2.new(700, 520) at = (view - size) / 2 end
        local width = math.max(1, math.min(options.width or 510, size.X - 24, view.X - 24))
        local height = math.max(1, math.min(options.height or 570, size.Y - 24, view.Y - 24))
        local x = at.X + size.X - 12 - width / 2
        local y = at.Y + size.Y / 2
        x = math.clamp(x, width / 2 + 12, math.max(width / 2 + 12, view.X - width / 2 - 12))
        y = math.clamp(y, height / 2 + 12, math.max(height / 2 + 12, view.Y - height / 2 - 12))
        self.panel.Size = UDim2.fromOffset(width, height)
        self.panel.Position = UDim2.fromOffset(x, y)
        if self.onLayout then self.onLayout(width, height) end
    end
    self:Connect(self.scrim.MouseButton1Click, function() self:Close() end)
    self:Connect(self.closeButton.MouseButton1Click, function() self:Close() end)
    self:Connect(input.InputBegan, function(key)
        if key.KeyCode == Enum.KeyCode.Escape then self:Close() end
    end)
    self:Connect(self.root:GetPropertyChangedSignal("AbsoluteSize"), function() self:Layout() end)
    self:Connect(window.main:GetPropertyChangedSignal("AbsoluteSize"), function() self:Layout() end)
    self:Connect(window.main:GetPropertyChangedSignal("AbsolutePosition"), function() self:Layout() end)
    self:Layout()
    local scale = window:Create("UIScale", { Parent = self.panel, Scale = 0.96 })
    game:GetService("TweenService"):Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    return self
end

function Surface:Connect(signal, callback)
    return self.window:ConnectFor(self, signal, callback)
end

function Surface:Close()
    if self.closed then return end
    self.closed = true
    if self.window._conexaoModal == self then self.window._conexaoModal = nil end
    self.window:DisconnectMany(self, table.clone(self.connections))
    if self.onClose then self.onClose() end
    self.window:DestroySubtree(self.root)
end

return Surface
