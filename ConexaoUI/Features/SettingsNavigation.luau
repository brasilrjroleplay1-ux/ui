--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Keep controls on their native tab; category visibility also owns their separate descriptors.
local Preferences = require(script.Parent.Preferences)
local Navigation = {}
local definitions = { { "appearance", "Aparência", 102 }, { "themes", "Temas", 76 }, { "saving", "Salvamento", 114 }, { "controls", "Controles", 100 } }
function Navigation.attach(window, membership)
    local tab = window.SettingsTab
    local self = { window = window, tab = tab, name = "Categorias", __type = "SettingsNavigation", buttons = {}, membership = membership, connections = {}, shown = not window.hidden }
    window.SettingsNavigation = self
    local function create(class, props, theme) return window:Create(class, props, theme) end
    self.main = create("Frame", { Name = "SettingsCategories", Parent = tab.tabPage, Size = UDim2.new(1, -24, 0, 46), BackgroundTransparency = 1, BorderSizePixel = 0 })
    self.scroller = create("ScrollingFrame", { Parent = self.main, Name = "CategoryBar", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.fromOffset(418, 0), ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 2,
        ScrollBarImageTransparency = 0.5, ClipsDescendants = true, Active = true, ScrollingEnabled = true, CanvasPosition = Vector2.new(), ElasticBehavior = Enum.ElasticBehavior.Never,
    }, { ScrollBarImageColor3 = "AccentColor" })
    create("UIPadding", { Parent = self.scroller, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 7), PaddingLeft = UDim.new(0, 1), PaddingRight = UDim.new(0, 1) })
    create("UIListLayout", { Parent = self.scroller, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    local width = 2
    for i, definition in ipairs(definitions) do
        local key, title, size = definition[1], definition[2], definition[3]
        local offset = width + (i > 1 and 6 or 0)
        width += size + (i > 1 and 6 or 0)
        local button = create("TextButton", { Parent = self.scroller, Name = key, Text = title, TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0,
            Size = UDim2.fromOffset(size, 32), LayoutOrder = i, BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 8,
        }, { FontFace = "TitleFont", TextColor3 = "ContentColor", BackgroundColor3 = "AccentColor" })
        create("UICorner", { Parent = button, CornerRadius = UDim.new(0, 8) })
        local stroke = create("UIStroke", { Parent = button, Thickness = 1, Transparency = 1 }, { Color = "AccentStroke" })
        self.buttons[key] = { button = button, stroke = stroke, offset = offset }
        window:ConnectFor(self, button.MouseButton1Click, function() if window:_interactive() then self:Select(key, true) end end)
    end
    self.scroller.CanvasSize = UDim2.fromOffset(width, 0)
    function self:Layout()
        local current = self.buttons[self.active]
        if not current then return end
        local view = self.scroller.AbsoluteWindowSize.X
        if view <= 0 then view = self.main.AbsoluteSize.X end
        if view <= 0 then return end
        local x = self.scroller.CanvasPosition.X
        x = math.min(x, current.offset)
        x = math.max(x, current.offset + current.button.Size.X.Offset - view)
        self.scroller.CanvasPosition = Vector2.new(math.clamp(x, 0, math.max(0, width - view)), 0)
    end
    function self:Paint(animate)
        for key, item in pairs(self.buttons) do
            local active = key == self.active
            window:_reveal(item.button, { BackgroundTransparency = self.shown and (active and 0.82 or 0.97) or 1, TextTransparency = self.shown and (active and 0 or 0.2) or 1 }, animate)
            window:_reveal(item.stroke, { Transparency = self.shown and (active and 0.38 or 0.87) or 1 }, animate)
        end
    end
    function self:Select(key, remember)
        assert(self.buttons[key], "Categoria de configurações inválida.")
        if window.unloaded then return end
        if window.WindowSizeSlider.dragging then window.WindowSizeSlider:_endDrag() end
        if window._conexaoPanel then window._conexaoPanel:Close() end
        self.active = key
        for control, category in pairs(self.membership) do control:_setShown(not window.hidden and category == key, false) end
        self:Paint(false)
        self:Layout()
        tab.tabPage.CanvasPosition = Vector2.new(0, 0)
        if tab._scrollController then tab._scrollController.desiredY, tab._scrollController.atEnd = 0, false tab._scrollController:Queue() end
        if remember then window.UIPreferences.settingsCategory = key Preferences.save(window) end
    end
    function self:_setShown(shown, animate)
        self.shown = shown
        self.main.Visible = true -- reserve the navigation row while native controls reveal
        self.scroller.ScrollBarImageTransparency = shown and 0.5 or 1
        self:Paint(animate)
    end
    function self:_refreshTheme() self:Paint(false) end
    window:ConnectFor(self, self.scroller:GetPropertyChangedSignal("AbsoluteWindowSize"), function() self:Layout() end)
    for control, category in pairs(membership) do
        local show = control._setShown
        function control:_setShown(shown, animate)
            show(self, shown, animate)
            local visible = window.SettingsNavigation.active == category
            self.main.Visible = visible
            if self.descriptor and self.descriptor.main.Parent == tab.tabPage then self.descriptor.main.Visible = visible end
        end
    end
    tab:_register(self)
    self.main.LayoutOrder = -10000
    self:Select(self.buttons[window.UIPreferences.settingsCategory] and window.UIPreferences.settingsCategory or "appearance", false)
    return self
end
return Navigation
