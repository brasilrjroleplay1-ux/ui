--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Buttons = require(script.Parent.ActionButton)
local tweenService = game:GetService("TweenService")
local Card = {}
function Card.attach(group, title, icon, collapsed, onChange)
    if group.Card then return group.Card end
    local window = group.window
    local self = { group = group, collapsed = collapsed == true, shown = not window.hidden, height = 58 }
    group.Card = self
    group.name = title
    group.main.AutomaticSize, group.main.ClipsDescendants = Enum.AutomaticSize.None, true
    group.main.BackgroundColor3 = Color3.new(1, 1, 1)
    window:Create("UICorner", { Parent = group.main, CornerRadius = UDim.new(0, 13) })
    window:Create("UIGradient", { Parent = group.main, Rotation = 90 }, { Color = "ElementGradient" })
    self.rim = window:Create("UIStroke", { Parent = group.main, Thickness = 1, Transparency = 0.45 }, { Color = "SurfaceStroke" })
    local body = window:Create("Frame", { Name = "CardContents", Parent = group.main, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 64), Size = UDim2.new(1, 0, 0, 0), Visible = not self.collapsed })
    self.body, group.tabPage = body, body
    group.layout.Parent = body
    local customIcon = type(icon) == "number" or (type(icon) == "string" and (tonumber(icon) ~= nil or icon:find("://", 1, true) ~= nil))
    self.header = Buttons.new(window, group, group.main, title, customIcon and "folder" or (icon or "folder"), "tab", 12)
    if customIcon then
        window:DestroySubtrees(self.header.icon:GetChildren())
        local image = window:Create("ImageLabel", { Parent = self.header.icon, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 16,
            Image = tonumber(icon) and ("rbxassetid://" .. tostring(icon)) or icon,
        })
        self.header.glyph = { { node = image, color = "ImageColor3", alpha = "ImageTransparency" } }
    end
    self.header.label.TextTruncate = Enum.TextTruncate.AtEnd
    self.arrow = window:Create("TextLabel", { Name = "Expand", Parent = self.header.button, Text = "›", TextSize = 28,
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(24, 28), BackgroundTransparency = 1, ZIndex = 17,
    }, { TextColor3 = "ContentColor", FontFace = "TitleFont" })
    local show, refresh = group._setShown, group._refreshTheme
    function self:Layout(animate)
        if window.unloaded or not group.main.Parent then return end
        local width = group.main.AbsoluteSize.X
        if width <= 0 then return end
        self.lastWidth = width
        self.header.button.Size = UDim2.new(1, 0, 0, 58)
        self.header:Layout(width - 32, 58)
        self.header.active = false
        self.header:SetShown(self.shown, false)
        local content = group.layout.AbsoluteContentSize
        local bodyHeight = typeof(content) == "Vector2" and math.max(0, content.Y) or 0
        body.Size = UDim2.new(1, 0, 0, bodyHeight)
        body.Visible = not self.collapsed
        local height = self.collapsed and 58 or 74 + bodyHeight
        self.height = height
        local target = UDim2.new(group.main.Size.X.Scale, group.main.Size.X.Offset, 0, height)
        if self.tween then self.tween:Cancel() self.tween = nil end
        if self.arrowTween then self.arrowTween:Cancel() self.arrowTween = nil end
        if animate then
            self.tween = tweenService:Create(group.main, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = target })
            self.tween:Play()
            self.arrowTween = tweenService:Create(self.arrow, TweenInfo.new(0.2), { Rotation = self.collapsed and 0 or 90 })
            self.arrowTween:Play()
        else group.main.Size = target self.arrow.Rotation = self.collapsed and 0 or 90 end
        if self.onLayout then self.onLayout() end
    end
    function self:SetCollapsed(value)
        if window.unloaded or not group.main.Parent then return end
        if self.collapsed == (value == true) then return end
        self.collapsed = value == true
        if self.collapsed and window._conexaoPanel then
            local pane = window._conexaoPanel
            local at = pane.control and pane.control.main
            while at and at ~= group.main do at = at.Parent end
            if at == group.main then pane:Close() end
        end
        show(group, self.shown and not self.collapsed, false)
        self:Layout(not window.hidden)
        if onChange then onChange(self.collapsed) end
    end
    function group:SetCollapsed(value) self.Card:SetCollapsed(value) end
    function group:ToggleCollapsed() self:SetCollapsed(not self.Card.collapsed) end
    function group:IsCollapsed() return self.Card.collapsed end
    function group:Expand() self:SetCollapsed(false) end
    function group:Collapse() self:SetCollapsed(true) end
    function group:Layout() self.Card:Layout(false) end
    function group:_setShown(shown, animate)
        self.Card.shown = shown
        show(self, shown and not self.Card.collapsed, animate)
        self.Card.header:SetShown(shown, animate)
        window:_reveal(self.main, { BackgroundTransparency = shown and 0.06 or 1 }, animate)
        window:_reveal(self.Card.rim, { Transparency = shown and 0.45 or 1 }, animate)
        window:_reveal(self.Card.arrow, { TextTransparency = shown and 0.1 or 1 }, animate)
    end
    function group:_refreshTheme()
        refresh(self)
        self.Card.header:Paint(false)
    end
    window:ConnectFor(group, self.header.button.MouseButton1Click, function() if window:_interactive() then self:SetCollapsed(not self.collapsed) end end)
    window:ConnectFor(group, group.layout:GetPropertyChangedSignal("AbsoluteContentSize"), function() self:Layout(false) end)
    window:ConnectFor(group, group.main:GetPropertyChangedSignal("AbsoluteSize"), function()
        if group.main.AbsoluteSize.X ~= self.lastWidth then self:Layout(false) end
    end)
    window:ConnectFor(group, group.main.Destroying, function()
        if self.tween then self.tween:Cancel() end
        if self.arrowTween then self.arrowTween:Cancel() end
    end)
    self:Layout(false)
    group:_setShown(self.shown, false)
    return self
end
return Card
