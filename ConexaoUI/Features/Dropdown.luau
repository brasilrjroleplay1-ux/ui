--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Gen2 remains the control/state owner. Only its presentation of an open dropdown changes.
local Surface = require(script.Parent.Surface)
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

    function control:_close()
        if self.selectionPanel then self.selectionPanel:Close() end
        self._isOpen = false
        self.chevron.Rotation = 180
    end
    function control:_open()
        if self._isOpen or self.locked or self.window.unloaded then return end
        local w = self.window
        local modal = Surface.new(w, self.name, self.multiSelect and "Escolha uma ou mais opções" or "Escolha uma opção", { footer = true })
        self.selectionPanel, self._isOpen = modal, true
        self.chevron.Rotation = 0
        modal.onClose = function()
            self.selectionPanel, self._isOpen = nil, false
            if self.chevron.Parent then self.chevron.Rotation = 180 end
        end
        modal:Connect(self.main.Destroying, function() modal:Close() end)
        modal.search = w:Create("TextBox", {
            Name = "Filter", Parent = modal.content, Size = UDim2.new(1, 0, 0, 40),
            Text = "", PlaceholderText = "Buscar opção...", ClearTextOnFocus = false,
            TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
            BackgroundTransparency = 0.88, ZIndex = 4016,
        }, { TextColor3 = "ContentColor", FontFace = "Font", BackgroundColor3 = "AccentColor", PlaceholderColor3 = "PlaceholderColor" })
        Surface.round(w, modal.search, 11)
        w:Create("UIPadding", { Parent = modal.search, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
        modal.list = w:Create("ScrollingFrame", {
            Parent = modal.content, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -52),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
            ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 4012,
        }, { ScrollBarImageColor3 = "AccentColor" })
        modal.grid = w:Create("UIGridLayout", {
            Parent = modal.list, CellPadding = UDim2.fromOffset(10, 10), CellSize = UDim2.new(0.5, -7, 0, 50),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        w:Create("UIPadding", { Parent = modal.list, PaddingLeft = UDim.new(0, 2), PaddingTop = UDim.new(0, 2), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4) })
        modal.empty = Surface.label(w, modal.content, "Nenhuma opção encontrada", {
            Position = UDim2.fromOffset(0, 58), Size = UDim2.new(1, 0, 0, 44), TextXAlignment = Enum.TextXAlignment.Center, Visible = false,
        })
        modal.items, modal.optionConnections = {}, {}
        function modal:Sync()
            if self.closed then return end
            local query, count = string.lower(self.search.Text), 0
            for _, item in ipairs(self.items) do
                local chosen = table.find(control.value, item.name) ~= nil
                item.frame.Visible = query == "" or string.find(string.lower(item.name), query, 1, true) ~= nil
                if item.frame.Visible then count += 1 end
                item.frame.BackgroundTransparency = chosen and 0.65 or 0.95
                item.stroke.Transparency = chosen and 0.15 or 0.7
                item.marker.Text = chosen and "✓" or ""
                item.label.TextTransparency = chosen and 0 or 0.15
            end
            self.empty.Visible = count == 0
            self.subtitle.Text = control.multiSelect and (tostring(#control.value) .. " selecionadas · " .. tostring(count) .. " opções") or "Escolha uma opção"
        end
        function modal:Rebuild()
            if self.closed then return end
            w:DisconnectMany(self, self.optionConnections)
            self.optionConnections = {}
            local roots = {}
            for _, item in ipairs(self.items) do table.insert(roots, item.frame) end
            w:DestroySubtrees(roots)
            self.items = {}
            for index, name in ipairs(control.options) do
                local frame = w:Create("Frame", {
                    Name = name, Parent = self.list, BorderSizePixel = 0, LayoutOrder = index, ZIndex = 4013,
                }, { BackgroundColor3 = "AccentColor" })
                Surface.round(w, frame, 12)
                local stroke = w:Create("UIStroke", { Parent = frame, Thickness = 1 }, { Color = "AccentStroke" })
                local label = Surface.label(w, frame, name, {
                    Position = UDim2.fromOffset(12, 4), Size = UDim2.new(1, -46, 1, -8), TextSize = 13,
                })
                local marker = Surface.label(w, frame, "", {
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(22, 22), TextSize = 18,
                })
                local hit = w:Create("TextButton", {
                    Parent = frame, Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
                    Size = UDim2.fromScale(1, 1), ZIndex = 4017,
                })
                local item = { name = name, frame = frame, label = label, marker = marker, stroke = stroke, hit = hit }
                table.insert(self.items, item)
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
        end
        modal:Connect(modal.search:GetPropertyChangedSignal("Text"), function()
            modal.list.CanvasPosition = Vector2.new(0, 0)
            modal:Sync()
        end)
        local actions = {
            { "Padrão", function() control:Set(table.clone(default)) end },
            { "Limpar", function() control:Set({}) end },
        }
        if self.multiSelect then table.insert(actions, { "Selecionar todos", function() control:Set(table.clone(control.options)) end }) end
        modal.actions = {}
        for index, action in ipairs(actions) do
            local button = Surface.button(w, modal.footer, action[1], {
                Position = UDim2.new((index - 1) / #actions, index == 1 and 0 or 3, 0, 0),
                Size = UDim2.new(1 / #actions, -6, 1, 0), TextSize = 12,
            }, index == #actions)
            modal.actions[index] = button
            modal:Connect(button.MouseButton1Click, function() if not self.locked then action[2]() end end)
        end
        modal.onLayout = function(width)
            local cols = width < 420 and 1 or 2
            modal.grid.CellSize = UDim2.new(1 / cols, cols == 1 and -8 or -9, 0, 50)
        end
        modal:Layout()
        modal:Rebuild()
    end
    -- The inline card remains collapsed, even when the native methods refresh/filter options.
    control._resizeToOptions = function() end
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
