--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Responsive presentation only. Gen2 continues to own values, callbacks and persistence.
local metrics = require(script.Parent.Parent.Gen2.utility.textMetrics)
local textService = game:GetService("TextService")
local SliderInput = require(script.Parent.SliderInput)
local Controls = {}
local heightCache, heightCount = {}, 0

local function plain(node)
    local text = tostring(node.Text or "")
    return node.RichText and text:gsub("<.->", "") or text
end
local function fallbackHeight(text, size, width)
    local cell, lines, used = size * 0.6, 1, 0
    for word in string.gmatch(text, "%S+") do
        local length = (utf8.len(word) or #word) * cell
        if used > 0 and used + cell + length > width then lines += 1 used = 0 end
        if length > width then
            local count = math.ceil(length / width)
            lines += count - 1
            used = length - (count - 1) * width
        else used += (used > 0 and cell or 0) + length end
    end
    return math.ceil(lines * size * 1.2)
end
local function textHeight(node, size, width)
    width = math.max(1, math.floor(width))
    local text, font = plain(node), node.FontFace
    local key = tostring(font.Family) .. tostring(font.Weight) .. tostring(font.Style) .. size .. ":" .. width .. ":" .. text
    local function actual(height)
        local current, bounds = node.AbsoluteSize, node.TextBounds
        if typeof(current) == "Vector2" and typeof(bounds) == "Vector2" and math.abs(current.X - width) <= 1 and bounds.Y > 0 then
            return math.max(height, math.ceil(bounds.Y + 2))
        end
        return height
    end
    if heightCache[key] then return actual(heightCache[key]) end
    local ok, bounds = pcall(function()
        local params = Instance.new("GetTextBoundsParams")
        params.Text, params.Font, params.Size, params.Width = text, font, size, width
        local rich = pcall(function() params.RichText = node.RichText == true end)
        if rich then params.Text = tostring(node.Text or "") end
        return textService:GetTextBoundsAsync(params)
    end)
    local height = ok and typeof(bounds) == "Vector2" and bounds.Y or nil
    if not height or height < size then height = fallbackHeight(text, size, width) end
    -- Some environments report unwrapped bounds even with a width. Keep a safe fallback.
    if metrics.textWidth(font, size, text) > width and height <= size then height = fallbackHeight(text, size, width) end
    height = math.max(size + 2, math.ceil(height + 2))
    if heightCount >= 512 then heightCache, heightCount = {}, 0 end
    heightCache[key], heightCount = height, heightCount + 1
    return actual(height)
end
local function setHeight(control, height)
    height = math.ceil(height)
    local size = control.main.Size
    control.main.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, height)
    -- Keep MinSize <= MaxSize at every assignment, including when rows grow after wrapping.
    if height > control._controlLayout.height then
        control._controlConstraint.MaxSize = Vector2.new(math.huge, height)
        control._controlConstraint.MinSize = Vector2.new(0, height)
    else
        control._controlConstraint.MinSize = Vector2.new(0, height)
        control._controlConstraint.MaxSize = Vector2.new(math.huge, height)
    end
    control._controlLayout.height = height
end
local function label(control, width, height, size)
    local icon = control.iconLabel and 21 or 0
    control.container.AutomaticSize = Enum.AutomaticSize.None
    control.container.Size = UDim2.fromOffset(width, height)
    control.title.AutomaticSize = Enum.AutomaticSize.None
    control.title.TextSize = size
    control.title.TextWrapped, control.title.TextTruncate = true, Enum.TextTruncate.None
    control.title.TextYAlignment = Enum.TextYAlignment.Center
    control.title.Position = UDim2.fromOffset(icon, 0)
    control.title.Size = UDim2.new(1, -icon, 1, 0)
    if control.iconLabel then
        control.iconLabel.AnchorPoint = Vector2.new(0, 0.5)
        control.iconLabel.Position = UDim2.fromScale(0, 0.5)
    end
end
local function current(control, width)
    return not control.window.unloaded and control.main.Parent ~= nil and not control.dragging
        and math.abs(control.main.AbsoluteSize.X - width) < 1
end
local function slider(control, width)
    local inset = 22
    if control.minimal then
        setHeight(control, 41)
        control.track.AnchorPoint, control.track.Position = Vector2.new(0, 0.5), UDim2.new(0, 16 + inset, 0.5, 0)
        control.track.Size = UDim2.new(1, -32 - inset * 2, 0, 14)
        control.interact.Size = UDim2.new(1, inset * 2, 0, 32)
    else
        local size, inner = width < 320 and 14 or 16, math.max(1, width - 32)
        local icon = control.iconLabel and 21 or 0
        local titleWidth = metrics.textWidth(control.title.FontFace, size, plain(control.title))
        local valueWidth = 0
        for _, value in ipairs({ control.range[1], control.range[2], control.value }) do
            valueWidth = math.max(valueWidth, metrics.textWidth(control.title.FontFace, 15, control:_format(value)) + 12)
        end
        local valueHeight = control._valueInput and 30 or 18
        valueWidth = math.min(inner, control._valueInput and math.max(64, valueWidth + 12) or valueWidth)
        local trackWidth = math.min(240, math.floor(width * 0.42))
        local column = width - trackWidth - 32 - inset * 2 - 16
        local wide = width >= 560 and titleWidth + icon <= column and valueWidth <= column
        local separate = not wide and width < 320
        local room = wide and column or (separate and inner or math.max(1, inner - valueWidth - 12))
        local titleHeight = textHeight(control.title, size, room - icon)
        local heading = (wide or separate) and titleHeight + 4 + valueHeight or math.max(titleHeight, valueHeight)
        if not current(control, width) then return end
        -- Commit only after measurements finish: the viewport may change while fonts load.
        control.container.AnchorPoint = Vector2.new(0, 0)
        control.titleContainer.AnchorPoint, control.titleContainer.Position = Vector2.new(0, 0), UDim2.fromOffset(0, 0)
        control.titleContainer.Size = UDim2.fromOffset(room, titleHeight)
        control.valueHost.AutomaticSize, control.valueHost.ClipsDescendants = Enum.AutomaticSize.None, true
        control.valueHost.AnchorPoint, control.valueHost.Size = Vector2.new(0, 0), UDim2.fromOffset(valueWidth, valueHeight)
        control.title.AutomaticSize = Enum.AutomaticSize.None
        control.title.TextSize, control.title.TextWrapped, control.title.TextTruncate = size, true, Enum.TextTruncate.None
        control.title.TextYAlignment = Enum.TextYAlignment.Center
        control.title.Position, control.title.Size = UDim2.fromOffset(icon, 0), UDim2.new(1, -icon, 1, 0)
        if control.iconLabel then
            control.iconLabel.AnchorPoint = Vector2.new(0, 0.5)
            control.iconLabel.Position = UDim2.fromScale(0, 0.5)
        end
        if wide then
            local height = math.max(65, heading + 24)
            setHeight(control, height)
            control.container.Position, control.container.Size = UDim2.fromOffset(16, (height - heading) / 2), UDim2.fromOffset(column, heading)
            control.valueHost.Position = UDim2.fromOffset(0, titleHeight + 4)
            control.track.AnchorPoint, control.track.Position = Vector2.new(0, 0.5), UDim2.new(1, -16 - inset - trackWidth, 0.5, 0)
            control.track.Size = UDim2.fromOffset(trackWidth, 14)
            control._controlLayout.mode = "wide"
        else
            local trackY = 12 + heading + 22
            setHeight(control, trackY + 22 + 12)
            control.container.Position, control.container.Size = UDim2.fromOffset(16, 12), UDim2.fromOffset(inner, heading)
            control.valueHost.Position = separate and UDim2.fromOffset(0, titleHeight + 4) or UDim2.fromOffset(inner - valueWidth, 0)
            control.track.AnchorPoint, control.track.Position = Vector2.new(0, 0.5), UDim2.fromOffset(16 + inset, trackY)
            control.track.Size = UDim2.new(1, -32 - inset * 2, 0, 14)
            control._controlLayout.mode = separate and "compact" or "stacked"
        end
        control._layoutMode = control._controlLayout.mode
        control.interact.Size = UDim2.new(1, inset * 2, 0, 44)
    end
    control.interact.AnchorPoint, control.interact.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
end
local function row(control, width)
    local size, kind = width < 320 and 14 or 16, control.__type
    local icon = control.iconLabel and 21 or 0
    local inner, right, stacked = math.max(1, width - 32), 0, false
    if kind == "Toggle" then
        right = 50
        stacked = inner < right + 12 + 60 + icon
    elseif kind == "Input" or kind == "Keybind" then
        local text = kind == "Input" and (control.input.Text ~= "" and control.input.Text or control.placeholder) or control.keyLabel.Text
        right = math.min(inner, math.clamp(metrics.textWidth(control.title.FontFace, 15, text) + 30, kind == "Input" and 70 or 40, kind == "Input" and 220 or 200))
        stacked = metrics.textWidth(control.title.FontFace, size, plain(control.title)) + icon + right + 12 > inner
    end
    local room = stacked and inner or math.max(1, inner - (right > 0 and right + 12 or 0))
    local height = textHeight(control.title, size, room - icon)
    if not current(control, width) then return end
    local body = math.max(44, height + (stacked and 64 or 24))
    setHeight(control, body)
    label(control, room, height, size)
    control.container.AnchorPoint = Vector2.new(0, stacked and 0 or 0.5)
    control.container.Position = stacked and UDim2.fromOffset(16, 12) or UDim2.new(0, 16, 0.5, 0)
    if kind == "Toggle" then
        control.functionContainer.Position = stacked and UDim2.fromOffset(16, height + 22) or UDim2.new(1, -16, 0.5, 0)
        control.functionContainer.AnchorPoint = stacked and Vector2.new(0, 0) or Vector2.new(1, 0.5)
    elseif control.box then
        control.box.Size = UDim2.fromOffset(right, 30)
        control.box.AnchorPoint = Vector2.new(stacked and 0 or 1, stacked and 0 or 0.5)
        control.box.Position = stacked and UDim2.fromOffset(16, height + 22) or UDim2.new(1, -16, 0.5, 0)
    end
    control._controlLayout.mode = stacked and "stacked" or "row"
end

function Controls.attach(control)
    if not control or control._controlLayout then return end
    if control.__type == "Group" then for _, element in ipairs(control.elements or {}) do Controls.attach(element) end return end
    SliderInput.attach(control)
    if control.descriptor then Controls.attach(control.descriptor) end
    local kind = control.__type
    local descriptor = kind == "Descriptor"
    if not descriptor and (control.compact or not ({ Slider = true, Toggle = true, Button = true, Input = true, Keybind = true })[kind]) then return end
    local window, main = control.window, control.main
    local self = { pending = false, running = false, dirty = false, mode = nil, height = 0 }
    control._controlLayout = self
    local storage = window:Create("Frame", {
        Name = "ConexaoLayoutStorage", Parent = main, Visible = false,
        BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0),
    })
    local function detach(parent)
        if not parent then return end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("UIListLayout") or child:IsA("UIFlexItem") then
                local holder = window:Create("Frame", {
                    Name = "PreservedLayout", Parent = storage, Visible = false,
                    BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0),
                })
                child.Parent = holder
            end
        end
    end
    if descriptor then
        detach(main)
        main.AutomaticSize = Enum.AutomaticSize.None
    else
        detach(control.container)
        if kind == "Slider" and not control.minimal then detach(control.titleContainer) detach(control.title) end
    end
    control._controlConstraint = window:Create("UISizeConstraint", { Parent = main })
    local function apply()
        if window.unloaded or not main.Parent or control.dragging or window.animating or window._revealing or (window.hidden and window.hasShownOnce) then return end
        local width = main.AbsoluteSize.X
        if width <= 0 then return end
        if descriptor then
            local node = control.titleLabel
            local height = textHeight(node, 12, width)
            if not current(control, width) then return end
            node.AutomaticSize, node.TextWrapped = Enum.AutomaticSize.None, true
            node.Position, node.Size = UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, height)
            setHeight(control, height + 12)
        elseif kind == "Slider" then slider(control, width)
        else row(control, width) end
        if control.descriptor then Controls.attach(control.descriptor) end
    end
    function self:Request()
        if self.running then self.dirty = true return end
        if self.pending then return end
        self.pending = true
        task.defer(function()
            self.pending = false
            if window.unloaded or not main.Parent then return end
            self.running = true
            apply()
            self.running = false
            if self.dirty then self.dirty = false self:Request() end
        end)
    end
    control._layoutConexaoControl = function() self:Request() end
    if kind == "Slider" then
        control._applyLayout = control._layoutConexaoControl
        local finish = control._endDrag
        control._endDrag = function(c, ...) local result = finish(c, ...) self:Request() return result end
        local set = control.Set
        control.Set = function(c, ...) local result = set(c, ...) self:Request() return result end
    elseif kind == "Input" or kind == "Keybind" then control._sizeBox = control._layoutConexaoControl end
    window:ConnectFor(control, main:GetPropertyChangedSignal("AbsoluteSize"), function() self:Request() end)
    local title = descriptor and control.titleLabel or control.title
    if title then
        for _, property in ipairs({ "Text", "FontFace", "TextBounds" }) do
            window:ConnectFor(control, title:GetPropertyChangedSignal(property), function() self:Request() end)
        end
    end
    self:Request()
end

return Controls
