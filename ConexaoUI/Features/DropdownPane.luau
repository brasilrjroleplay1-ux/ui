--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Reserve part of the window's content area for options; native pages keep their own layout.
local Surface = require(script.Parent.Surface)
local input, run = game:GetService("UserInputService"), game:GetService("RunService")
local Pane = {}

local function contains(node, point)
    local p, s = node.AbsolutePosition, node.AbsoluteSize
    return point.X >= p.X and point.Y >= p.Y and point.X <= p.X + s.X and point.Y <= p.Y + s.Y
end
local function shifted(value, x, y)
    return UDim2.new(value.X.Scale, value.X.Offset + x, value.Y.Scale, value.Y.Offset + y)
end
local function assign(node, key, value)
    if node[key] ~= value then node[key] = value end
end

function Pane.new(window, control)
    if window._conexaoPanel then window._conexaoPanel:Close() end
    local self = {
        window = window, tab = window.selectedTab, connections = {}, closed = false, __type = "DropdownPane",
        baseSize = window.elements.Size, basePosition = window.elements.Position,
        baseFadeSize = window.bottomFade.Size, baseFadePosition = window.bottomFade.Position,
    }
    window._conexaoPanel = self
    local applyWidth = window._applyRailWidth
    local splitWidth
    function self:Connect(signal, callback) return window:ConnectFor(self, signal, callback) end
    function self:Close()
        if self.closed then return end
        self.closed = true
        if window._conexaoPanel == self then window._conexaoPanel = nil end
        window:DisconnectMany(self, table.clone(self.connections))
        if window._applyRailWidth == splitWidth then window._applyRailWidth = applyWidth end
        window.elements.Size, window.elements.Position = self.baseSize, self.basePosition
        window.bottomFade.Size, window.bottomFade.Position = self.baseFadeSize, self.baseFadePosition
        if not window.unloaded then applyWidth(window) end
        if self.onClose then self.onClose() end
        window:DestroySubtree(self.main)
        if window.RefreshContentLayouts and not window.unloaded then window:RefreshContentLayouts() end
    end
    self.main = window:Create("Frame", {
        Name = "DropdownPane", Parent = window.main, BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, Active = true, ClipsDescendants = true, ZIndex = 4010,
        Size = UDim2.fromOffset(1, 1),
    })
    self.root, self.panel = self.main, self.main
    Surface.round(window, self.main, 14)
    window:Create("UIGradient", { Parent = self.main, Rotation = 90 }, { Color = "WindowColor" })
    window:Create("UIStroke", { Parent = self.main, Thickness = 1, Transparency = 0.25 }, { Color = "AccentStroke" })
    -- Very short windows can scroll the entire options pane, keeping search and actions reachable.
    self.viewport = window:Create("ScrollingFrame", {
        Name = "OptionsViewport", Parent = self.main, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, Active = true, ClipsDescendants = true, AutomaticCanvasSize = Enum.AutomaticSize.None,
        CanvasSize = UDim2.new(), CanvasPosition = Vector2.new(), ScrollBarThickness = 3,
        ScrollingDirection = Enum.ScrollingDirection.Y, ElasticBehavior = Enum.ElasticBehavior.Never, ZIndex = 4011,
    }, { ScrollBarImageColor3 = "AccentColor" })
    self.body = window:Create("Frame", {
        Name = "OptionsBody", Parent = self.viewport, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 4011,
    })
    self.title = Surface.label(window, self.body, control.name, {
        Position = UDim2.fromOffset(16, 14), Size = UDim2.new(1, -66, 0, 22), TextSize = 17,
        TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    window.themeProperties[self.title].FontFace = { "TitleFont", function(font) return Font.new(font.Family, Enum.FontWeight.SemiBold, font.Style) end }
    self.title.FontFace = window.themeProperties[self.title].FontFace[2](window.theme.TitleFont)
    self.subtitle = Surface.label(window, self.body, "", {
        Position = UDim2.fromOffset(16, 37), Size = UDim2.new(1, -32, 0, 18), TextSize = 12, TextTransparency = 0.25,
        TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    self.closeButton = Surface.button(window, self.body, "×", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12), Size = UDim2.fromOffset(36, 36), TextSize = 22,
    })
    self.content = window:Create("Frame", {
        Parent = self.body, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 62),
        Size = UDim2.new(1, -24, 1, -122), ZIndex = 4011,
    })
    self.footer = window:Create("Frame", {
        Parent = self.body, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 1, -48),
        Size = UDim2.new(1, -24, 0, 36), ZIndex = 4011,
    })
    self.footerDivider = window:Create("Frame", {
        Parent = self.body, BorderSizePixel = 0, BackgroundTransparency = 0.65, Size = UDim2.new(1, -24, 0, 1), ZIndex = 4011,
    }, { BackgroundColor3 = "SurfaceStroke" })
    function self:Layout()
        if self.closed then return end
        if window.unloaded or window.hidden or window.minimised or not control.main.Parent or window.selectedTab ~= self.tab then self:Close() return end
        local ancestor = control.main
        while ancestor and ancestor ~= window.screenGui do
            if ancestor:IsA("GuiObject") and not ancestor.Visible then self:Close() return end
            ancestor = ancestor.Parent
        end
        local size = window.main.AbsoluteSize
        if size.X <= 0 or size.Y <= 0 then return end
        local width = math.max(1, size.X * self.baseSize.X.Scale + self.baseSize.X.Offset)
        local height = math.max(1, size.Y * self.baseSize.Y.Scale + self.baseSize.Y.Offset)
        local anchor = window.elements.AnchorPoint
        local left = size.X * self.basePosition.X.Scale + self.basePosition.X.Offset - width * anchor.X
        local top = size.Y * self.basePosition.Y.Scale + self.basePosition.Y.Offset - height * anchor.Y
        local paneWidth, paneHeight, x, y, reserveX, reserveY
        if width >= 420 then
            self.mode = "right"
            -- Leave a usable controls column while allowing two option cards per row.
            paneWidth, paneHeight = math.min(440, math.floor(width * 0.55), width - 198), math.max(1, height - 16)
            x, y = left + width - paneWidth - 8, top + 8
            reserveX, reserveY = paneWidth + 18, 0
        else
            self.mode = "bottom"
            paneWidth, paneHeight = math.max(1, width - 16), math.max(1, math.floor(height * 0.56))
            x, y = left + 8, top + height - paneHeight - 8
            reserveX, reserveY = 0, math.min(height - 1, paneHeight + 18)
        end
        self.bounds = { x = left, y = top, width = width, height = height }
        assign(window.elements, "Size", shifted(self.baseSize, -reserveX, -reserveY))
        assign(window.elements, "Position", shifted(self.basePosition, -reserveX * anchor.X, -reserveY * anchor.Y))
        assign(window.bottomFade, "Size", shifted(self.baseFadeSize, -reserveX, 0))
        assign(window.bottomFade, "Position", shifted(self.baseFadePosition, -reserveX, -reserveY))
        assign(self.main, "Position", UDim2.fromOffset(x, y))
        assign(self.main, "Size", UDim2.fromOffset(paneWidth, paneHeight))
        local footerWidth = math.max(1, paneWidth - 24)
        local stacked = footerWidth < 180
        local count = #(self.actionViews or {})
        local inline = count == 3 and footerWidth >= 368
        local rows = count == 0 and 0 or (inline and 1 or (stacked and count or (count > 2 and 2 or 1)))
        local footerHeight = rows * 44 + math.max(0, rows - 1) * 8
        local bodyHeight = math.max(count == 0 and 194 or footerHeight + 204, paneHeight)
        self.footerMode = count == 0 and "none" or (inline and "inline" or (stacked and "stacked" or "split"))
        self.footer.Visible, self.footerDivider.Visible = count > 0, count > 0
        assign(self.body, "Size", UDim2.new(1, 0, 0, bodyHeight))
        assign(self.footer, "Position", UDim2.fromOffset(12, bodyHeight - footerHeight - 12))
        assign(self.footer, "Size", UDim2.fromOffset(footerWidth, footerHeight))
        assign(self.footerDivider, "Position", UDim2.fromOffset(12, bodyHeight - footerHeight - 24))
        assign(self.content, "Size", UDim2.new(1, -24, 0, bodyHeight - (count == 0 and 74 or footerHeight + 86)))
        for index, view in ipairs(self.actionViews or {}) do
            local width, x, y = footerWidth, 0, (index - 1) * 52
            if inline then
                local secondary = math.floor((footerWidth - 16) * 0.25)
                width, x, y = index == 3 and footerWidth - secondary * 2 - 16 or secondary, (index - 1) * (secondary + 8), 0
            elseif not stacked then
                width, x, y = index == 3 and footerWidth or (footerWidth - 8) / 2, index == 2 and (footerWidth + 8) / 2 or 0, index == 3 and 52 or 0
            end
            assign(view.button, "Position", UDim2.fromOffset(x, y))
            assign(view.button, "Size", UDim2.fromOffset(width, 44))
            view:Layout(width, 44)
        end
        if self.LayoutOptions then self:LayoutOptions(paneWidth - 24) end
        assign(self.viewport, "CanvasSize", UDim2.fromOffset(0, bodyHeight))
        assign(self.viewport, "CanvasPosition", Vector2.new(0, math.clamp(self.viewport.CanvasPosition.Y, 0, bodyHeight - paneHeight)))
        self.viewport.ScrollingEnabled = bodyHeight > paneHeight
        self.viewport.ScrollBarImageTransparency = bodyHeight > paneHeight and 0.4 or 1
        local scrollReady = not window.animating and not window._revealing
            and not (window.WindowSizeSlider and window.WindowSizeSlider.dragging)
        if scrollReady and not self.scrollReady then
            for _, scroll in ipairs(self._scrollers or {}) do scroll:Queue() end
        end
        self.scrollReady = scrollReady
    end
    splitWidth = function(w, ...)
        if self.closed then return applyWidth(w, ...) end
        -- Native rail layout writes the full area. Reapply the split without accumulating offsets.
        w.elements.Size, w.elements.Position = self.baseSize, self.basePosition
        w.bottomFade.Size, w.bottomFade.Position = self.baseFadeSize, self.baseFadePosition
        local result = applyWidth(w, ...)
        self.baseSize, self.baseFadeSize = w.elements.Size, w.bottomFade.Size
        self:Layout()
        return result
    end
    window._applyRailWidth = splitWidth
    self:Connect(self.closeButton.MouseButton1Click, function() self:Close() end)
    self:Connect(input.InputBegan, function(key)
        if key.KeyCode == Enum.KeyCode.Escape then self:Close()
        elseif key.UserInputType == Enum.UserInputType.MouseButton1 or key.UserInputType == Enum.UserInputType.Touch then
            if key.Position and not contains(window.main, key.Position) then self:Close() end
        end
    end)
    self:Connect(run.Heartbeat, function() self:Layout() end)
    self:Connect(window.main:GetPropertyChangedSignal("AbsoluteSize"), function() self:Layout() end)
    self:Connect(control.main.Destroying, function() self:Close() end)
    return self
end

return Pane
