--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Gen2 remains the control/state owner. Only its presentation of an open dropdown changes.
local Surface = require(script.Parent.Surface)
local Pane = require(script.Parent.DropdownPane)
local Buttons = require(script.Parent.ActionButton)
local Scrolling = require(script.Parent.Scrolling)
local metrics = require(script.Parent.Parent.Gen2.utility.textMetrics)
local Dropdown = {}

function Dropdown.attach(control, props)
    if control._conexaoDropdown then return control end
    control._conexaoDropdown = true
    local default
    if props then default = props.value or props.Value or props.currentOption or props.CurrentOption
    else default = control.value end
    if type(default) == "string" then default = { default } end
    default = type(default) == "table" and table.clone(default) or {}
    control.defaultValue = default
    control.panel.Visible = false
    if not props or not (props.placeholder or props.Placeholder) then control.placeholderText = "Selecionar" end
    control._updateSelectedLabel = function()
        control.selectedLabel.Text = #control.value == 0 and control.placeholderText
            or (#control.value == 1 and control.value[1] or (tostring(#control.value) .. " selecionadas"))
    end
    control._updateSelectedLabel()
    local function layoutHeader()
        local width = control.main.AbsoluteSize.X
        if width <= 0 then return end
        local leftWidth = math.max(1, width - 241)
        local textWidth = metrics.textWidth(control.title.FontFace, control.title.TextSize, control.title.Text)
        if control.window.unloaded or not control.main.Parent or control.main.AbsoluteSize.X ~= width then return end
        local narrow = width < 400 or textWidth + (control.icon and 24 or 0) > leftWidth
        local height = narrow and 70 or 41
        control.main.Size = UDim2.new(1, -20, 0, height)
        control.top.Size, control.interact.Size = UDim2.new(1, 0, 0, height), UDim2.new(1, 0, 0, height)
        control.container.AnchorPoint = Vector2.new(0, narrow and 0 or 0.5)
        control.container.Position = narrow and UDim2.fromOffset(20, 10) or UDim2.new(0, 20, 0.5, 0)
        control.container.Size = narrow and UDim2.new(1, -60, 0, 20) or UDim2.fromOffset(leftWidth, 20)
        control.title.AutomaticSize = Enum.AutomaticSize.None
        control.title.Size = UDim2.new(1, control.icon and -24 or 0, 0, 20)
        control.title.TextWrapped, control.title.TextTruncate = false, Enum.TextTruncate.AtEnd
        control.selectedLabel.AnchorPoint = narrow and Vector2.new(0, 0) or Vector2.new(1, 0.5)
        control.selectedLabel.Position = narrow and UDim2.fromOffset(20, 38) or UDim2.new(1, -41, 0.5, 0)
        control.selectedLabel.Size = narrow and UDim2.new(1, -60, 0, 20) or UDim2.fromOffset(168, 15)
        control.selectedLabel.TextXAlignment = narrow and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        control.selectedLabel.TextWrapped, control.selectedLabel.TextTruncate = false, Enum.TextTruncate.AtEnd
    end
    control.window:ConnectFor(control, control.main:GetPropertyChangedSignal("AbsoluteSize"), layoutHeader)
    control.window:ConnectFor(control, control.title:GetPropertyChangedSignal("Text"), layoutHeader)
    control.window:ConnectFor(control, control.title:GetPropertyChangedSignal("FontFace"), layoutHeader)
    control._layoutConexaoHeader = layoutHeader
    layoutHeader()

    function control:_close()
        if self.selectionPanel then self.selectionPanel:Close() end
        self._isOpen = false
        self.chevron.Rotation = 180
    end
    function control:_open()
        if self._isOpen or self.locked or self.window.unloaded then return end
        local w = self.window
        local picker = Pane.new(w, self)
        self.selectionPanel, self._isOpen = picker, true
        self.chevron.Rotation = 0
        picker.onClose = function()
            self.selectionPanel, self._isOpen = nil, false
            if self.chevron.Parent then self.chevron.Rotation = 180 end
        end
        picker.search = w:Create("TextBox", {
            Name = "Filter", Parent = picker.content, Size = UDim2.new(1, 0, 0, 40),
            Text = "", PlaceholderText = "Buscar opção...", ClearTextOnFocus = false,
            TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
            BackgroundTransparency = 0.88, ZIndex = 4016,
        }, { TextColor3 = "ContentColor", FontFace = "Font", BackgroundColor3 = "AccentColor", PlaceholderColor3 = "PlaceholderColor" })
        Surface.round(w, picker.search, 11)
        w:Create("UIPadding", { Parent = picker.search, PaddingLeft = UDim.new(0, 36), PaddingRight = UDim.new(0, 12) })
        w:Create("UIStroke", { Parent = picker.search, Thickness = 1, Transparency = 0.72 }, { Color = "SurfaceStroke" })
        local searchIcon = w:Create("Frame", { Name = "SearchIcon", Parent = picker.content, Position = UDim2.fromOffset(13, 13), Size = UDim2.fromOffset(11, 11), BackgroundTransparency = 1, ZIndex = 4017 })
        Surface.round(w, searchIcon, 20)
        w:Create("UIStroke", { Parent = searchIcon, Thickness = 1.5, Transparency = 0.3 }, { Color = "ContentColor" })
        w:Create("Frame", { Parent = searchIcon, Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(6, 1.5), Rotation = 45, BorderSizePixel = 0, BackgroundTransparency = 0.3, ZIndex = 4017 }, { BackgroundColor3 = "ContentColor" })
        picker.list = w:Create("ScrollingFrame", {
            Parent = picker.content, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -52),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
            ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 4012,
        }, { ScrollBarImageColor3 = "AccentColor" })
        picker.grid = w:Create("UIGridLayout", {
            Parent = picker.list, CellPadding = UDim2.fromOffset(8, 8), CellSize = UDim2.fromOffset(140, 56),
            FillDirectionMaxCells = 2, SortOrder = Enum.SortOrder.LayoutOrder,
        })
        Scrolling.frame(w, picker, picker.list, picker.grid)
        w:Create("UIPadding", { Parent = picker.list, PaddingLeft = UDim.new(0, 2), PaddingTop = UDim.new(0, 2), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4) })
        picker.empty = Surface.label(w, picker.content, "Nenhuma opção encontrada", {
            Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 0, 56), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, Visible = false,
        })
        picker.items, picker.optionConnections = {}, {}
        function picker:LayoutOptions(width)
            local inner = math.max(1, width - 8)
            local columns = inner >= 272 and 2 or 1
            local cellSize = UDim2.fromOffset(math.floor((inner - (columns - 1) * 8) / columns), 56)
            if self.grid.CellSize ~= cellSize then self.grid.CellSize = cellSize end
            self.grid.FillDirectionMaxCells, self.columns = columns, columns
        end
        function picker:PaintItem(item)
            local chosen = table.find(control.value, item.name) ~= nil
            local accent, base = w.theme.AccentColor, w.theme.NeutralButton
            item.frame.BackgroundColor3 = base:Lerp(accent, chosen and 0.25 or (item.hovered and 0.1 or 0.025))
            item.stroke.Color = chosen and w.theme.AccentStroke or w.theme.SurfaceStroke
            item.stroke.Transparency = chosen and 0.08 or (item.hovered and 0.25 or 0.6)
            item.frame.BackgroundTransparency = 0
            item.marker.Text = chosen and "✓" or ""
            item.label.TextColor3 = Buttons.readableColor(w.theme.ContentColor, item.frame.BackgroundColor3)
            item.marker.TextColor3 = item.label.TextColor3
            item.label.TextTransparency = 0
        end
        function picker:Sync()
            if self.closed then return end
            local query, count = string.lower(self.search.Text), 0
            for _, item in ipairs(self.items) do
                item.frame.Visible = query == "" or string.find(string.lower(item.name), query, 1, true) ~= nil
                if item.frame.Visible then count += 1 end
                self:PaintItem(item)
            end
            self.empty.Visible = count == 0
            self.subtitle.Text = control.multiSelect and ("Escolha várias · " .. tostring(#control.value) .. " selecionadas") or "Escolha uma"
        end
        function picker:Rebuild()
            if self.closed then return end
            w:DisconnectMany(self, self.optionConnections)
            self.optionConnections = {}
            local roots = {}
            for _, item in ipairs(self.items) do table.insert(roots, item.frame) end
            w:DestroySubtrees(roots)
            self.items = {}
            for index, name in ipairs(control.options) do
                local frame = w:Create("Frame", {
                    Name = name, Parent = self.list, Size = UDim2.new(1, -8, 0, 56), BorderSizePixel = 0, LayoutOrder = index, ZIndex = 4013,
                })
                Surface.round(w, frame, 12)
                local stroke = w:Create("UIStroke", { Parent = frame, Thickness = 1 })
                local label = Surface.label(w, frame, name, {
                    Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -54, 1, -16), TextSize = 14,
                    TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd,
                })
                w.themeProperties[label].FontFace = { "Font", function(font) return Font.new(font.Family, Enum.FontWeight.SemiBold, font.Style) end }
                -- State colours are painted together, so a theme tween cannot overwrite contrast.
                w.themeProperties[label].TextColor3 = nil
                label.FontFace = w.themeProperties[label].FontFace[2](w.theme.Font)
                local checkbox = w:Create("Frame", {
                    Name = "SelectionMark", Parent = frame, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4014,
                })
                local marker = Surface.label(w, checkbox, "", {
                    Size = UDim2.fromScale(1, 1), TextSize = 17, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4015,
                })
                w.themeProperties[marker].TextColor3 = nil
                local hit = w:Create("TextButton", {
                    Parent = frame, Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
                    Size = UDim2.fromScale(1, 1), ZIndex = 4017,
                })
                local item = { name = name, frame = frame, label = label, marker = marker, checkbox = checkbox, stroke = stroke, hit = hit }
                table.insert(self.items, item)
                local function hover(value)
                    if self.closed then return end
                    item.hovered = value and not control.locked
                    self:PaintItem(item)
                end
                for _, signal in ipairs({ hit.MouseEnter, hit.SelectionGained }) do
                    table.insert(self.optionConnections, self:Connect(signal, function() hover(true) end))
                end
                for _, signal in ipairs({ hit.MouseLeave, hit.SelectionLost }) do
                    table.insert(self.optionConnections, self:Connect(signal, function() hover(false) end))
                end
                table.insert(self.optionConnections, self:Connect(hit.MouseButton1Click, function()
                    if control.locked then return end
                    if control.multiSelect then
                        local value = table.clone(control.value)
                        local at = table.find(value, name)
                        if at then table.remove(value, at) else table.insert(value, name) end
                        control:Set(value)
                    else
                        control:Set(name)
                        self:Close()
                    end
                end))
            end
            self:Sync()
            self:Layout()
        end
        picker:Connect(picker.search:GetPropertyChangedSignal("Text"), function()
            picker.list.CanvasPosition = Vector2.new(0, 0)
            picker:Sync()
        end)
        local actions = self.multiSelect and {
            { "Padrão", function() control:Set(table.clone(default)) end },
            { "Limpar", function() control:Set({}) end },
        } or {}
        if self.multiSelect then table.insert(actions, { "Selecionar todos", function() control:Set(table.clone(control.options)) end }) end
        picker.actions, picker.actionViews = {}, {}
        for index, action in ipairs(actions) do
            local symbol = ({ "restore", "clear", "select" })[index]
            local view = Buttons.new(w, picker, picker.footer, action[1], symbol, index == 3 and "primary" or "secondary", 4015)
            picker.actions[index], picker.actionViews[index] = view.button, view
            picker:Connect(view.button.MouseButton1Click, function() if not self.locked then action[2]() end end)
        end
        function picker:RefreshTheme()
            for _, view in ipairs(self.actionViews) do view:Paint(false) end
            self:Sync()
        end
        picker:Layout()
        picker:Rebuild()
    end
    -- The inline card remains collapsed, even when the native methods refresh/filter options.
    control._resizeToOptions = function() end
    local lock = control.Lock
    function control:Lock(...)
        self:_close()
        return lock(self, ...)
    end
    for _, name in ipairs({ "Set", "Refresh", "Add", "Remove" }) do
        local original = control[name]
        control[name] = function(self, ...)
            local result = original(self, ...)
            if self.selectionPanel then
                if name == "Set" then self.selectionPanel:Sync() else self.selectionPanel:Rebuild() end
            end
            return result
        end
    end
    control.Open, control.Close = control._open, control._close
    return control
end

return Dropdown
