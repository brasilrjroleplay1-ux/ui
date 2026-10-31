--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Inline numeric editing; the native slider still owns Set, callbacks and persistence.
local variables = require(script.Parent.Parent.Gen2.utility.variables)
local Input = {}
local function finite(value) return type(value) == "number" and value == value and value > -math.huge and value < math.huge end
local function trim(text) return tostring(text):match("^%s*(.-)%s*$") end
local function decimals(value)
    for places = 0, 6 do if math.abs(value * 10 ^ places - math.round(value * 10 ^ places)) < 1e-8 then return places end end
    return 6
end
function Input.prepare(props)
    local format = props.format or props.Format
    if format ~= nil then
        assert(type(format) == "string", "Slider format must be 'number' or 'percent'.")
        format = format:lower()
        if format == "percentage" then format = "percent" end
        assert(format == "number" or format == "percent", "Slider format must be 'number' or 'percent'.")
        props.suffix, props.Suffix = format == "percent" and "%" or "", nil
    end
    return props
end

function Input.attach(control, props)
    if not control or control.__type ~= "Slider" or control._valueInputConfigured then return end
    control._valueInputConfigured = true
    props = props or {}
    local editable = props.editable
    if editable == nil then editable = props.Editable end
    if control.minimal or editable == false or not control.valueHost then return end
    local window, host = control.window, control.valueHost
    local self = { editing = false, hovered = false, shown = not window.hidden, glyph = {} }
    control._valueInput = self
    control._decimals = math.max(control._decimals, decimals(control.range[1]), decimals(control.range[2]))
    control.valueOdo:snap(control:_format(control.value))
    local function numeric(value) return string.format("%." .. control._decimals .. "f", value) end
    local function parse(text)
        text = trim(text)
        if #text > 128 then return nil end
        local suffix = trim(control.suffix)
        if suffix ~= "" and text:sub(-#suffix):lower() == suffix:lower() then text = trim(text:sub(1, -#suffix - 1)) end
        text = text:gsub(",", ".")
        if not text:match("^[+-]?%d+%.?%d*$") and not text:match("^[+-]?%d*%.%d+$") then return nil end
        local value = tonumber(text)
        return finite(value) and value or nil
    end
    -- Move the odometer's owned children into a display layer. An overlay must not become
    -- another item in its UIListLayout, or it would push the digits out of the value field.
    local children = host:GetChildren()
    self.readout = window:Create("Frame", { Name = "SliderReadout", Parent = host, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -44, 1, 0), ZIndex = 7 })
    for _, child in ipairs(children) do child.Parent = self.readout end
    self.readoutScale = window:Create("UIScale", { Parent = self.readout, Scale = 1 })
    control.valueOdo.container = self.readout
    window.themeProperties[host] = window.themeProperties[host] or {}
    window.themeProperties[host].BackgroundColor3 = "NeutralButton"
    host.BackgroundColor3 = window.theme.NeutralButton
    window:Create("UICorner", { Parent = host, CornerRadius = UDim.new(0, 7) })
    self.stroke = window:Create("UIStroke", { Parent = host, Thickness = 1, Transparency = 1 })
    self.icon = window:Create("Frame", { Name = "EditHint", Parent = host, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(16, 16), ZIndex = 11 })
    local function pencil(x, y, width, height, rotation, outline)
        local part = window:Create("Frame", { Parent = self.icon, BackgroundTransparency = 1, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, height), Rotation = rotation, ZIndex = 11 })
        window:Create("UICorner", { Parent = part, CornerRadius = UDim.new(0, 0.7) })
        if outline then
            local stroke = window:Create("UIStroke", { Parent = part, Thickness = 1.4, Transparency = 1 })
            table.insert(self.glyph, { node = stroke, color = "Color", alpha = "Transparency" })
        else table.insert(self.glyph, { node = part, color = "BackgroundColor3", alpha = "BackgroundTransparency" }) end
    end
    pencil(8.5, 7.5, 11, 4, -45, true)
    pencil(11.5, 4.5, 1.4, 4, -45, false)
    pencil(3, 13, 3, 2, -45, false)
    self.button = window:Create("TextButton", { Name = "EditSliderValue", Parent = host, Text = "", TextTransparency = 1, AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 12 })
    self.editor = window:Create("TextBox", {
        Name = "SliderValueInput", Parent = host, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1, Text = numeric(control.value), TextSize = 15, TextTransparency = 0,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, MultiLine = false, TextWrapped = false,
        Visible = false, ZIndex = 13,
    }, { FontFace = "Font", TextColor3 = "ContentColor" })
    control.valueInput = self.editor
    function self:Layout(width, height, textWidth)
        local available = math.max(1, width - 44)
        local scale = math.min(1, available / math.max(1, textWidth))
        self.readoutScale.Scale = scale
        self.readout.Size = UDim2.fromOffset(available / scale, height / scale)
    end
    function self:Paint(shown, animate)
        if window.unloaded or not host.Parent then return end
        self.shown = shown
        local active = not control.locked and (self.editing or self.hovered)
        window:_reveal(host, { BackgroundTransparency = shown and (active and 0.05 or 0.25) or 1 }, animate)
        window:_reveal(self.stroke, { Color = active and window.theme.AccentColor or window.theme.SurfaceStroke,
            Transparency = shown and (active and 0.2 or 0.5) or 1 }, animate)
        for _, mark in ipairs(self.glyph) do
            window:_reveal(mark.node, { [mark.color] = window.theme.ContentColor,
                [mark.alpha] = shown and (control.locked and 0.65 or (active and 0 or 0.15)) or 1 }, animate)
        end
    end
    function self:Finish(commit)
        if not self.editing then return false end
        local value = commit and not control.locked and parse(self.editor.Text) or nil
        self.editing = false
        self.editor.Visible, self.readout.Visible, self.button.Visible = false, true, true
        self.editor:ReleaseFocus()
        if window.unloaded or not control.main.Parent then return false end
        if value ~= nil then
            value = math.clamp(value, control.range[1], control.range[2])
            local snapped = math.clamp(control.range[1] + math.round((value - control.range[1]) / control.increment) * control.increment, control.range[1], control.range[2])
            if snapped ~= control.value then control:Set(value) end
        end
        if window.unloaded or not control.main.Parent then return value ~= nil end
        self.editor.Text = numeric(control.value)
        self:Paint(self.shown, false)
        return value ~= nil
    end
    function self:Begin()
        if self.editing or window.unloaded or control.locked or not window:_interactive() or not control.main.Parent then return end
        if control.dragging then control:_endDrag() end
        self.editing = true
        self.editor.Text = numeric(control.value)
        self.editor.Visible, self.readout.Visible, self.button.Visible = true, false, false
        self:Paint(true, false)
        self.editor:CaptureFocus()
        self.editor.CursorPosition, self.editor.SelectionStart = #self.editor.Text + 1, 1
    end
    window:ConnectFor(control, self.button.MouseButton1Click, function() self:Begin() end)
    for _, signal in ipairs({ self.button.MouseEnter, self.button.SelectionGained }) do
        window:ConnectFor(control, signal, function()
            if window:_interactive() and not control.locked then self.hovered = true self:Paint(self.shown, true) end
        end)
    end
    for _, signal in ipairs({ self.button.MouseLeave, self.button.SelectionLost }) do
        window:ConnectFor(control, signal, function() self.hovered = false self:Paint(self.shown, true) end)
    end
    window:ConnectFor(control, self.editor.FocusLost, function(_, input)
        self:Finish(not (input and input.KeyCode == Enum.KeyCode.Escape))
    end)
    window:ConnectFor(control, variables.userInputService.InputBegan, function(input)
        if self.editing and input.KeyCode == Enum.KeyCode.Escape then self:Finish(false) end
    end)
    window:ConnectFor(control, variables.userInputService.WindowFocusReleased, function() self:Finish(true) end)
    local set = control.Set
    control.Set = function(c, ...)
        local result = set(c, ...)
        if not self.editing and not window.unloaded and self.editor.Parent then self.editor.Text = numeric(c.value) end
        return result
    end
    local shown = control._setShown
    control._setShown = function(c, value, animate)
        if not value and self.editing then self:Finish(not window.unloaded) end
        if not value then self.hovered = false end
        if window.unloaded or not c.main.Parent then return end
        shown(c, value, animate)
        self:Paint(value, animate)
    end
    local refresh = control._refreshTheme
    control._refreshTheme = function(c, ...)
        refresh(c, ...)
        self:Paint(self.shown, false)
    end
    for _, method in ipairs({ "Lock", "Unlock" }) do
        local native = control[method]
        control[method] = function(c, ...)
            self:Finish(false)
            local result = native(c, ...)
            self.hovered = false
            self:Paint(self.shown, false)
            return result
        end
    end
    self:Paint(self.shown, false)
end
return Input
