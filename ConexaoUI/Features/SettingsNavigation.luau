--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Keep controls on their native tab; category visibility also owns their separate descriptors.
local Preferences = require(script.Parent.Preferences)
local Buttons = require(script.Parent.ActionButton)
local Navigation = {}
local definitions = { { "appearance", "Aparência", 132 }, { "themes", "Temas", 108 }, { "saving", "Salvamento", 146 }, { "controls", "Controles", 128 } }
function Navigation.attach(window, membership)
    local tab = window.SettingsTab
    local self = { window = window, tab = tab, name = "Categorias", __type = "SettingsNavigation", buttons = {}, membership = membership, connections = {}, shown = not window.hidden }
    window.SettingsNavigation = self
    local function create(class, props, theme) return window:Create(class, props, theme) end
    self.main = create("Frame", { Name = "SettingsCategories", Parent = tab.tabPage, Size = UDim2.new(1, -24, 0, 66), BackgroundTransparency = 1, BorderSizePixel = 0 })
    self.scroller = create("ScrollingFrame", { Parent = self.main, Name = "CategoryBar", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 2,
        ScrollBarImageTransparency = 1, ClipsDescendants = true, Active = true, ScrollingEnabled = true, CanvasPosition = Vector2.new(), ElasticBehavior = Enum.ElasticBehavior.Never,
    }, { ScrollBarImageColor3 = "AccentColor", BackgroundColor3 = "StatBackground" })
    create("UICorner", { Parent = self.scroller, CornerRadius = UDim.new(0, 14) })
    self.rim = create("UIStroke", { Parent = self.scroller, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
    for _, definition in ipairs(definitions) do
        local key, title = definition[1], definition[2]
        local view = Buttons.new(window, self, self.scroller, title, key, "tab", 8)
        self.buttons[key] = { button = view.button, stroke = view.stroke, view = view, offset = 0, minimum = definition[3] }
        window:ConnectFor(self, view.button.MouseButton1Click, function() if window:_interactive() then self:Select(key, true) end end)
    end
    function self:Layout()
        if window.unloaded then return end
        local width = self.scroller.AbsoluteWindowSize.X
        if width <= 0 then width = self.main.AbsoluteSize.X end
        if width <= 0 then return end
        self.mode = width >= 560 and "row" or (width >= 300 and "grid" or "scroll")
        local height = self.mode == "grid" and 124 or 66
        local size = UDim2.new(1, -24, 0, height)
        if self.main.Size ~= size then self.main.Size = size end
        local x, total = 8, width
        for index, definition in ipairs(definitions) do
            local item = self.buttons[definition[1]]
            local buttonWidth, y = item.minimum, 8
            if self.mode == "row" then buttonWidth += (width - 554) / 4
            elseif self.mode == "grid" then
                buttonWidth = (width - 24) / 2
                x, y = 8 + ((index - 1) % 2) * (buttonWidth + 8), index > 2 and 66 or 8
            end
            item.offset = x
            item.button.Position, item.button.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(buttonWidth, 50)
            item.view:Layout(buttonWidth, 50)
            if self.mode ~= "grid" then x += buttonWidth + 8 end
        end
        if self.mode == "scroll" then total = x end
        self.scroller.CanvasSize = UDim2.fromOffset(total, height)
        self.overflow = total > width
        self.scroller.ScrollBarImageTransparency = self.shown and self.overflow and 0.4 or 1
        local at = 0
        local current = self.buttons[self.active]
        if self.overflow and current then
            at = math.min(self.scroller.CanvasPosition.X, current.offset - 8)
            at = math.max(at, current.offset + current.button.Size.X.Offset + 8 - width)
        end
        self.scroller.CanvasPosition = Vector2.new(math.clamp(at, 0, math.max(0, total - width)), 0)
    end
    function self:Paint(animate)
        window:_reveal(self.scroller, { BackgroundTransparency = self.shown and 0.58 or 1 }, animate)
        window:_reveal(self.rim, { Transparency = self.shown and 0.7 or 1 }, animate)
        for key, item in pairs(self.buttons) do
            item.view.active = key == self.active
            item.view:SetShown(self.shown, animate)
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
        self.scroller.ScrollBarImageTransparency = shown and self.overflow and 0.4 or 1
        self:Paint(animate)
    end
    function self:_refreshTheme() self:Paint(false) end
    window:ConnectFor(self, self.scroller:GetPropertyChangedSignal("AbsoluteWindowSize"), function() self:Layout() end)
    window:ConnectFor(self, self.main:GetPropertyChangedSignal("AbsoluteSize"), function() self:Layout() end)
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
