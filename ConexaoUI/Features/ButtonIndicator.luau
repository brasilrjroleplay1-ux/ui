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
    -- A right arrow has a shaft, unlike the chevron used by expandable controls.
    for _, part in ipairs({ { 13, 14, 12, 0 }, { 17, 11, 8, 45 }, { 17, 17, 8, -45 } }) do
        local mark = window:Create("Frame", {
            Name = "ActionArrow", Parent = self.plate, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(part[1], part[2]),
            Size = UDim2.fromOffset(part[3], 1.8), Rotation = part[4], BorderSizePixel = 0, ZIndex = 4,
        })
        window:Create("UICorner", { Parent = mark, CornerRadius = UDim.new(1, 0) })
        table.insert(self.glyph, mark)
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
