--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- A bounded, anchored surface. It never changes the selected tab or consumes layout space.
local Surface = require(script.Parent.Surface)
local input, run, gui = game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("GuiService")
local Popover = {}

local function contains(node, point)
    local p, s = node.AbsolutePosition, node.AbsoluteSize
    return point.X >= p.X and point.Y >= p.Y and point.X <= p.X + s.X and point.Y <= p.Y + s.Y
end

function Popover.new(window, control)
    if window._conexaoPanel then window._conexaoPanel:Close() end
    local self = { window = window, tab = window.selectedTab, connections = {}, closed = false, __type = "DropdownPopover" }
    window._conexaoPanel = self
    function self:Connect(signal, callback) return window:ConnectFor(self, signal, callback) end
    function self:Close()
        if self.closed then return end
        self.closed = true
        if window._conexaoPanel == self then window._conexaoPanel = nil end
        window:DisconnectMany(self, table.clone(self.connections))
        if self.onClose then self.onClose() end
        window:DestroySubtree(self.main)
    end
    self.main = window:Create("Frame", {
        Name = "DropdownPopover", Parent = window.screenGui, BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, Active = true, ClipsDescendants = true, ZIndex = 4010,
        Size = UDim2.fromOffset(300, 300),
    })
    self.root, self.panel = self.main, self.main
    Surface.round(window, self.main, 14)
    window:Create("UIGradient", { Parent = self.main, Rotation = 90 }, { Color = "WindowColor" })
    window:Create("UIStroke", { Parent = self.main, Thickness = 1, Transparency = 0.25 }, { Color = "AccentStroke" })
    self.title = Surface.label(window, self.main, control.name, {
        Position = UDim2.fromOffset(14, 12), Size = UDim2.new(1, -60, 0, 22), TextSize = 15,
        TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    self.subtitle = Surface.label(window, self.main, "", {
        Position = UDim2.fromOffset(14, 36), Size = UDim2.new(1, -28, 0, 18), TextSize = 11, TextTransparency = 0.25,
    })
    self.closeButton = Surface.button(window, self.main, "×", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(32, 32), TextSize = 20,
    })
    self.content = window:Create("Frame", {
        Parent = self.main, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 62),
        Size = UDim2.new(1, -24, 1, -122), ZIndex = 4011,
    })
    self.footer = window:Create("Frame", {
        Parent = self.main, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 1, -48),
        Size = UDim2.new(1, -24, 0, 36), ZIndex = 4011,
    })
    function self:Layout()
        if self.closed then return end
        if window.unloaded or window.hidden or window.minimised or not control.main.Parent or window.selectedTab ~= self.tab then self:Close() return end
        local ancestor = control.main
        while ancestor and ancestor ~= window.screenGui do
            if ancestor:IsA("GuiObject") and not ancestor.Visible then self:Close() return end
            ancestor = ancestor.Parent
        end
        local camera = workspace.CurrentCamera
        local view = camera and camera.ViewportSize or window.screenGui.AbsoluteSize
        if not view or view.X <= 0 or view.Y <= 0 then return end
        local top, bottom = Vector2.new(0, 0), Vector2.new(0, 0)
        local ok, a, b = pcall(gui.GetGuiInset, gui)
        if ok and typeof(a) == "Vector2" then top = a end
        if ok and typeof(b) == "Vector2" then bottom = b end
        local left, upper = top.X + 8, top.Y + 8
        local right, lower = view.X - bottom.X - 8, view.Y - bottom.Y - 8
        local width = math.min(300, math.max(1, right - left))
        local height = math.min(168 + math.clamp(#control.options, 1, 5) * 44, math.max(1, lower - upper))
        local p, s = control.main.AbsolutePosition, control.main.AbsoluteSize
        -- Close once the anchor scrolls outside its owning viewport.
        local parent = control.main.Parent
        while parent and parent ~= window.screenGui do
            if parent:IsA("ScrollingFrame") then
                local at, size = parent.AbsolutePosition, parent.AbsoluteSize
                if p.Y + s.Y <= at.Y or p.Y >= at.Y + size.Y then self:Close() return end
            end
            parent = parent.Parent
        end
        local x, y, side = p.X + s.X + 8, p.Y, "right"
        if x + width > right then
            if p.X - width - 8 >= left then x, side = p.X - width - 8, "left"
            else
                x, y, side = p.X + s.X - width, p.Y + s.Y + 8, "below"
                if y + height > lower and p.Y - height - 8 >= upper then y, side = p.Y - height - 8, "above" end
            end
        end
        x, y = math.clamp(x, left, math.max(left, right - width)), math.clamp(y, upper, math.max(upper, lower - height))
        -- Layout signals can arrive during a resize animation, when Scrolling defers writes.
        local scrollReady = not window.animating and not window._revealing
            and not (window.WindowSizeSlider and window.WindowSizeSlider.dragging)
        if scrollReady and not self.scrollReady then
            for _, scroll in ipairs(self._scrollers or {}) do scroll:Queue() end
        end
        self.scrollReady = scrollReady
        local signature = string.format("%g:%g:%g:%g", x, y, width, height)
        self.side = side
        if self.geometry == signature then return end
        self.geometry = signature
        self.main.Position, self.main.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(width, height)
    end
    self:Connect(self.closeButton.MouseButton1Click, function() self:Close() end)
    self:Connect(input.InputBegan, function(key)
        if key.KeyCode == Enum.KeyCode.Escape then self:Close()
        elseif key.UserInputType == Enum.UserInputType.MouseButton1 or key.UserInputType == Enum.UserInputType.Touch then
            local point = key.Position
            if point and not contains(self.main, point) and not contains(control.main, point) then self:Close() end
        end
    end)
    self:Connect(run.Heartbeat, function() self:Layout() end)
    self:Connect(control.main.Destroying, function() self:Close() end)
    return self
end

return Popover
