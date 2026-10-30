--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Temporary native content pages for pickers. No fullscreen overlay or screen dimming.
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
    if window._conexaoPanel then window._conexaoPanel:Close() end
    options = options or {}
    local previous = window.selectedTab
    local tab = window:CreateTab({ name = title, neglectSelector = true, forgetState = true })
    local self = setmetatable({ window = window, tab = tab, previousTab = previous, connections = {}, closed = false, __type = "ContentPicker" }, Surface)
    window._conexaoPanel = self
    self.root = tab.tabPage
    if options.fitViewport then
        self.root.ScrollingEnabled = false
        self.root.CanvasPosition = Vector2.new(0, 0)
    end
    self.main = window:Create("Frame", {
        Name = "ContentPicker", Parent = self.root, BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 340), BorderSizePixel = 0,
    })
    self.panel = self.main
    self.title = Surface.label(window, self.main, title, {
        Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -86, 0, 28), TextSize = 21,
    })
    self.subtitle = Surface.label(window, self.main, subtitle or "", {
        Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 28), TextSize = 12, TextTransparency = 0.25,
    })
    self.closeButton = Surface.button(window, self.main, "Voltar", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(74, 32), TextSize = 12,
    })
    self.content = window:Create("Frame", {
        Parent = self.main, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 76),
        Size = UDim2.new(1, 0, 1, options.footer and -132 or -76), ZIndex = 4011,
    })
    if options.footer then
        self.footer = window:Create("Frame", {
            Parent = self.main, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -42),
            Size = UDim2.new(1, 0, 0, 42), ZIndex = 4011,
        })
    end
    function self:Layout()
        if self.closed then return end
        local size = window.elements.AbsoluteSize
        local height
        if options.fitViewport then
            local view = self.root.AbsoluteWindowSize
            local available = typeof(view) == "Vector2" and view.Y > 0 and math.min(view.Y, size.Y) or size.Y
            height = math.max(1, available - 44)
        else
            height = math.max(240, size.Y - 44)
        end
        local width = math.max(1, size.X - 40)
        self.main.Size = UDim2.new(1, -20, 0, height)
        if self.onLayout then self.onLayout(width, height) end
    end
    function self:_setShown() end
    self:Connect(self.closeButton.MouseButton1Click, function() self:Close() end)
    self:Connect(input.InputBegan, function(key)
        if key.KeyCode == Enum.KeyCode.Escape then self:Close() end
    end)
    self:Connect(window.elements:GetPropertyChangedSignal("AbsoluteSize"), function() self:Layout() end)
    if options.fitViewport then
        self:Connect(self.root:GetPropertyChangedSignal("AbsoluteWindowSize"), function() self:Layout() end)
    end
    self:Layout()
    tab:_register(self)
    local remove = tab.Remove
    self._removeTab = remove
    function tab:Remove()
        if self._picker and not self._picker.closed then self._picker:Close()
        else remove(self) end
    end
    tab._picker = self
    tab:Select()
    return self
end

function Surface:Connect(signal, callback)
    return self.window:ConnectFor(self, signal, callback)
end

function Surface:Close(restore)
    if self.closed then return end
    self.closed = true
    local window = self.window
    if window._conexaoPanel == self then window._conexaoPanel = nil end
    window:DisconnectMany(self, table.clone(self.connections))
    if self.onClose then self.onClose() end
    if window.selectedTab == self.tab then
        if restore ~= false and not window.unloaded then
            local target = self.previousTab
            if not target or not target.tabPage or not table.find(window.tabs, target) then target = window.SettingsTab end
            if target then target:Select(true) else window.selectedTab = nil end
        else window.selectedTab = nil end
    end
    self._removeTab(self.tab)
    self.tab._picker = nil
end

return Surface
