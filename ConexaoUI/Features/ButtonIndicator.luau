--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- A persistent action mark; the native button still owns its hit target and callback.
local tweenService = game:GetService("TweenService")
local Buttons = require(script.Parent.ActionButton)
local Indicator = {}

function Indicator.attach(control)
    if control.__type ~= "Button" or control._buttonIndicator then return end
    local window = control.window
    local self = { shown = not window.hidden, hovered = false, pressed = false, glyph = {} }
    control._buttonIndicator = self
    self.plate = window:Create("Frame", {
        Name = "ButtonAction", Parent = control.compact and control.interact or control.main,
        Size = UDim2.fromOffset(28, 28), AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0), LayoutOrder = 2,
        BackgroundTransparency = 1, BorderSizePixel = 0, Active = false, ZIndex = 3,
    })
    window:Create("UICorner", { Parent = self.plate, CornerRadius = UDim.new(0, 8) })
    self.stroke = window:Create("UIStroke", { Parent = self.plate, Thickness = 1, Transparency = 1 })
    self.scale = window:Create("UIScale", { Parent = self.plate, Scale = 1 })
    -- A pointing hand and tap rays stay sharp and available without an image asset.
    local function line(name, x1, y1, x2, y2)
        local dx, dy = x2 - x1, y2 - y1
        local mark = window:Create("Frame", {
            Name = name, Parent = self.plate, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
            Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy) + 0.6, 1.5),
            Rotation = math.deg(math.atan2(dy, dx)), BorderSizePixel = 0, Active = false, ZIndex = 4,
        })
        window:Create("UICorner", { Parent = mark, CornerRadius = UDim.new(1, 0) })
        table.insert(self.glyph, mark)
    end
    local outline = {
        { 10, 14 }, { 10, 7 }, { 10.6, 5.5 }, { 12, 5 }, { 13.4, 5.5 }, { 14, 7 }, { 14, 12 },
        { 15, 11.5 }, { 16.4, 11.8 }, { 17, 13 }, { 18, 12.6 }, { 19.3, 13 }, { 20, 14.5 },
        { 21, 14.2 }, { 22, 15 }, { 22.5, 16.2 }, { 22, 21 }, { 20.5, 24 }, { 12.3, 24 },
        { 10.7, 23 }, { 5.7, 17.6 }, { 5.5, 16.3 }, { 6.4, 15.4 }, { 7.7, 15.5 }, { 10, 17.5 },
    }
    for index = 2, #outline do
        local previous, point = outline[index - 1], outline[index]
        line("ClickHand", previous[1], previous[2], point[1], point[2])
    end
    for _, ray in ipairs({ { 5, 8, 7.5, 8 }, { 6.4, 2.8, 8.3, 4.5 }, { 12, 1, 12, 3 }, { 17.5, 2.8, 15.7, 4.5 } }) do
        line("ClickRay", ray[1], ray[2], ray[3], ray[4])
    end
    function self:Paint(animate)
        if window.unloaded or not self.plate.Parent then return end
        local active = self.shown and not control.locked
        local hover, press = active and self.hovered, active and self.pressed
        local base, accent = window.theme.NeutralButton, window.theme.AccentColor
        local fill = base:Lerp(accent, press and 0.38 or (hover and 0.3 or 0.2))
        window:_reveal(self.plate, { BackgroundColor3 = fill, BackgroundTransparency = self.shown and (control.locked and 0.5 or 0) or 1 }, animate)
        window:_reveal(self.stroke, { Color = accent, Transparency = self.shown and (control.locked and 0.85 or (hover and 0.25 or 0.65)) or 1 }, animate)
        for _, mark in ipairs(self.glyph) do
            window:_reveal(mark, { BackgroundColor3 = Buttons.readableColor(window.theme.ContentColor, fill), BackgroundTransparency = self.shown and (control.locked and 0.65 or 0) or 1 }, animate)
        end
        if self.tween then self.tween:Cancel() self.tween = nil end
        if animate then
            self.tween = tweenService:Create(self.scale, TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = press and 0.9 or 1 })
            self.tween:Play()
        else self.scale.Scale = press and 0.9 or 1 end
    end
    local show, refresh = control._setShown, control._refreshTheme
    function control:_setShown(shown, animate)
        show(self, shown, animate)
        self._buttonIndicator.shown = shown
        if not shown then self._buttonIndicator.hovered, self._buttonIndicator.pressed = false, false end
        self._buttonIndicator:Paint(animate)
    end
    function control:_refreshTheme(...)
        if refresh then refresh(self, ...) end
        self._buttonIndicator:Paint(false)
    end
    for _, method in ipairs({ "Lock", "Unlock" }) do
        local native = control[method]
        control[method] = function(c, ...)
            local result = native(c, ...)
            self.hovered, self.pressed = false, false
            self:Paint(true)
            return result
        end
    end
    if control.compact then
        self.plate.AnchorPoint, self.plate.Position = Vector2.new(0, 0), UDim2.fromOffset(0, 0)
        local minWidth = control._minWidth
        control._minWidth = function(c) return minWidth(c) + 34 end
        control.tab:_wrapChild(control)
    end
    local function connect(signal, fn) window:ConnectFor(control, signal, fn) end
    local function enter() if window:_interactive() and not control.locked then self.hovered = true self:Paint(true) end end
    local function leave() self.hovered, self.pressed = false, false self:Paint(true) end
    connect(control.main.MouseEnter, enter)
    connect(control.main.MouseLeave, leave)
    connect(control.interact.SelectionGained, enter)
    connect(control.interact.SelectionLost, leave)
    connect(control.interact.InputBegan, function(key)
        if window:_interactive() and not control.locked and (key.UserInputType == Enum.UserInputType.Touch or key.UserInputType == Enum.UserInputType.MouseButton1) then self.pressed = true self:Paint(true) end
    end)
    connect(control.interact.InputEnded, function(key)
        if key.UserInputType == Enum.UserInputType.Touch or key.UserInputType == Enum.UserInputType.MouseButton1 then self.pressed = false self:Paint(true) end
    end)
    connect(self.plate.Destroying, function() if self.tween then self.tween:Cancel() end end)
    self:Paint(false)
end

return Indicator
