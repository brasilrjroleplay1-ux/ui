--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Inline sections share the native Settings page, its controls and its vertical scroll.
local Preferences = require(script.Parent.Preferences)
local Buttons = require(script.Parent.ActionButton)
local Navigation = {}
local definitions = {
    { "appearance", "Aparência", "Janela, transparência e navegação" },
    { "themes", "Temas", "Cores e prévias das paletas" },
    { "saving", "Salvamento", "Sua conta, preferências e configurações" },
    { "controls", "Controles", "Atalho, cursor e respostas da interface" },
    { "performance", "Desempenho", "Gráficos, limite de FPS e métricas" },
}

function Navigation.attach(window, membership)
    local tab = window.SettingsTab
    local self = { window = window, tab = tab, name = "Configurações", __type = "Section", sections = {}, membership = membership, connections = {}, mode = "sections", active = "appearance" }
    window.SettingsNavigation = self
    self.buttons = self.sections -- Keep existing integrations that inspect the named sections.
    local originals = table.clone(tab.elements)
    local saved = window.UIPreferences.settingsSections or {}
    window.UIPreferences.settingsSections = table.clone(saved)
    local function create(class, props, theme) return window:Create(class, props, theme) end
    self.main = create("Frame", { Name = "SettingsHeading", Parent = tab.tabPage, Size = UDim2.new(1, -24, 0, 56), BackgroundTransparency = 1, BorderSizePixel = 0 })
    self.title = create("TextLabel", { Parent = self.main, Text = "Configurações", TextSize = 22, Position = UDim2.fromOffset(4, 0), Size = UDim2.new(1, -8, 0, 28),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5,
    }, { TextColor3 = "ContentColor", FontFace = "TitleFont" })
    self.subtitle = create("TextLabel", { Parent = self.main, Text = "Abra uma seção para ajustar sua interface.", TextSize = 12, Position = UDim2.fromOffset(4, 32), Size = UDim2.new(1, -8, 0, 18),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5,
    }, { TextColor3 = { "ContentColor", function(color) return window.theme.MutedContent or color end }, FontFace = "Font" })
    function self:_setShown(shown, animate)
        window:_reveal(self.title, { TextTransparency = shown and 0 or 1 }, animate)
        window:_reveal(self.subtitle, { TextTransparency = shown and 0 or 1 }, animate)
    end
    function self:_refreshTheme() end
    tab:_register(self)
    tab:_moveElement(self, 1)
    local nextIndex = 2
    for _, definition in ipairs(definitions) do
        local key, title, caption = table.unpack(definition)
        local expanded = saved[key]
        if expanded == nil then expanded = key == "appearance" end
        local section = { window = window, tab = tab, name = title, __type = "Section", expanded = expanded, connections = {} }
        self.sections[key] = section
        section.main = create("Frame", { Name = key .. "SettingsSection", Parent = tab.tabPage, Size = UDim2.new(1, -24, 0, 60), BackgroundTransparency = 1, BorderSizePixel = 0 })
        local view = Buttons.new(window, section, section.main, title, key, "section", 4)
        section.view, section.button = view, view.button
        view.button.Size = UDim2.fromScale(1, 1)
        section.caption = create("TextLabel", { Parent = view.content, Text = caption, TextSize = 12, BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 8,
        }, { TextColor3 = { "ContentColor", function(color) return window.theme.MutedContent or color end }, FontFace = "Font" })
        section.arrow = create("TextLabel", { Name = "ExpandSection", Parent = view.button, Text = "›", TextSize = 26, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(24, 28), ZIndex = 9,
        }, { TextColor3 = "ContentColor", FontFace = "TitleFont" })
        section.divider = create("Frame", { Parent = section.main, Position = UDim2.new(0, 12, 1, -1), Size = UDim2.new(1, -24, 0, 1), BorderSizePixel = 0, ZIndex = 4 }, { BackgroundColor3 = "SurfaceStroke" })
        function section:Layout()
            local width = self.main.AbsoluteSize.X
            if width <= 0 then return end
            view:Layout(math.max(1, width - 32), 60)
            view.label.Position, view.label.Size = UDim2.fromOffset(32, 8), UDim2.new(1, -32, 0, 21)
            self.caption.Position, self.caption.Size = UDim2.fromOffset(32, 31), UDim2.new(1, -32, 0, 18)
            self.arrow.Rotation = self.expanded and 90 or 0
        end
        function section:_setShown(shown, animate)
            view:SetShown(shown, animate)
            window:_reveal(self.caption, { TextTransparency = shown and 0 or 1 }, animate)
            window:_reveal(self.arrow, { TextTransparency = shown and 0.15 or 1, Rotation = self.expanded and 90 or 0 }, animate)
            window:_reveal(self.divider, { BackgroundTransparency = shown and 0.65 or 1 }, animate)
        end
        function section:_refreshTheme() view:Paint(false) end
        window:ConnectFor(section, view.button.MouseButton1Click, function()
            if window:_interactive() then self:SetExpanded(key, not section.expanded, true) end
        end)
        window:ConnectFor(section, section.main:GetPropertyChangedSignal("AbsoluteSize"), function() section:Layout() end)
        tab:_register(section)
        tab:_moveElement(section, nextIndex)
        nextIndex += 1
        for _, control in ipairs(originals) do
            if membership[control] == key then tab:_moveElement(control, nextIndex) nextIndex += 1 end
        end
        section:Layout()
    end
    function self:Layout()
        for _, section in pairs(self.sections) do section:Layout() end
    end
    function self:Refresh()
        for control in pairs(self.membership) do control:_setShown(not window.hidden and not window.minimised, false) end
    end
    local function categoryOf(control)
        while control and control ~= tab do
            if membership[control] then return membership[control] end
            control = control.tab
        end
    end
    function self:SetExpanded(key, expanded, remember)
        local section = assert(self.sections[key], "Seção de configurações inválida.")
        if window.unloaded then return end
        if window.WindowSizeSlider.dragging and key == "appearance" then window.WindowSizeSlider:_endDrag() end
        if not expanded and window._conexaoPanel and categoryOf(window._conexaoPanel.control) == key then window._conexaoPanel:Close() end
        if not expanded and categoryOf(window._recordingKeybind) == key then window._recordingKeybind:_stopRecording() end
        section.expanded = expanded == true
        section:_setShown(not window.hidden and not window.minimised, true)
        for control, category in pairs(self.membership) do
            if category == key then
                if not expanded and control.__type == "Input" then control.input:ReleaseFocus() end
                control:_setShown(not window.hidden and not window.minimised, false)
            end
        end
        if tab._scrollController then tab._scrollController:Queue() end
        if remember then
            window.UIPreferences.settingsSections[key] = section.expanded
            Preferences.save(window)
        end
    end
    function self:ScrollTo(key)
        if window.unloaded or window._searching then return end
        local frame, section = tab.tabPage, self.sections[key]
        local offset = math.max(0, section.main.AbsolutePosition.Y - frame.AbsolutePosition.Y + frame.CanvasPosition.Y - 10)
        local scroll = tab._scrollController
        if scroll then scroll.atEnd, scroll.desiredY = false, offset scroll:Queue()
        else frame.CanvasPosition = Vector2.new(0, offset) end
    end
    function self:Select(key, remember)
        local section = assert(self.sections[key], "Seção de configurações inválida.")
        if not section.expanded then self.pendingFocus = key end
        self.active = key
        self:SetExpanded(key, true, remember)
        self:ScrollTo(key)
        task.defer(function() self:ScrollTo(key) end)
    end
    for control, key in pairs(membership) do
        local show = control._setShown
        function control:_setShown(shown, animate)
            local home = self.main.Parent == tab.tabPage
            local visible = self.__type ~= "Section" and (not home or window.SettingsNavigation.sections[key].expanded)
            show(self, shown and visible, animate)
            if home then
                self.main.Visible = visible and (self.__type ~= "ThemeGallery" or shown)
                if self.descriptor and self.descriptor.main.Parent == tab.tabPage then self.descriptor.main.Visible = visible end
            end
        end
    end
    local select = tab.Select
    function tab:Select(...)
        local result = select(self, ...)
        self.window.SettingsNavigation:Refresh()
        return result
    end
    local search = window.searchAction and window.searchAction.callback
    if search then
        window.searchAction.callback = function(...)
            local result = search(...)
            self:Refresh()
            return result
        end
    end
    window:ConnectFor(self, tab.tabPageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        local key = self.pendingFocus
        self.pendingFocus = nil
        if key then self:ScrollTo(key) end
    end)
    self:Refresh()
    self:Layout()
    return self
end
return Navigation
