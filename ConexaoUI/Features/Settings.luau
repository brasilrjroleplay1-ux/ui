--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Surface = require(script.Parent.Surface)
local Themes = require(script.Parent.Themes)
local Preferences = require(script.Parent.Preferences)
local Settings = {}

-- These are Roblox GuiObjects using the actual palette; no image downloads or AI previews.
local function cards(window, parent, owner, entries, z)
    local results = {}
    for index, entry in ipairs(entries) do
        local theme = entry.theme
        local card = window:Create("Frame", {
            Parent = parent, Name = entry.id, LayoutOrder = index, BorderSizePixel = 0,
            BackgroundColor3 = theme.StatBackground, ZIndex = z,
        })
        Surface.round(window, card, 12)
        local stroke = window:Create("UIStroke", { Parent = card, Color = theme.AccentStroke, Transparency = 0.8, Thickness = 1 })
        local mini = window:Create("Frame", {
            Parent = card, Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 90),
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = z + 1,
        })
        Surface.round(window, mini, 8)
        window:Create("UIGradient", { Parent = mini, Color = theme.WindowColor, Rotation = 35 })
        local rail = window:Create("Frame", {
            Parent = mini, Position = UDim2.fromOffset(7, 7), Size = UDim2.new(0.23, 0, 1, -14),
            BackgroundColor3 = theme.NeutralButton, BorderSizePixel = 0, ZIndex = z + 2,
        })
        Surface.round(window, rail, 5)
        for line = 1, 3 do
            local pill = window:Create("Frame", {
                Parent = rail, Position = UDim2.new(0, 4, 0, 8 + (line - 1) * 17), Size = UDim2.new(1, -8, 0, 9),
                BackgroundColor3 = line == 1 and theme.AccentColor or theme.ContentColor,
                BackgroundTransparency = line == 1 and 0 or 0.84, BorderSizePixel = 0, ZIndex = z + 3,
            })
            Surface.round(window, pill, 3)
        end
        local heading = window:Create("Frame", {
            Parent = mini, Position = UDim2.new(0.3, 0, 0, 12), Size = UDim2.new(0.4, 0, 0, 5),
            BackgroundColor3 = theme.ContentColor, BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = z + 2,
        })
        Surface.round(window, heading, 2)
        local track = window:Create("Frame", {
            Parent = mini, Position = UDim2.new(0.3, 0, 0, 34), Size = UDim2.new(0.59, 0, 0, 7),
            BackgroundColor3 = theme.SliderBackground, BorderSizePixel = 0, ZIndex = z + 2,
        })
        Surface.round(window, track, 4)
        local progress = window:Create("Frame", {
            Parent = track, Size = UDim2.new(0.68, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = z + 3,
        })
        Surface.round(window, progress, 4)
        window:Create("UIGradient", { Parent = progress, Color = theme.SliderProgress })
        local toggle = window:Create("Frame", {
            Parent = mini, Position = UDim2.new(0.3, 0, 0, 57), Size = UDim2.fromOffset(32, 16),
            BackgroundColor3 = theme.AccentColor, BorderSizePixel = 0, ZIndex = z + 2,
        })
        Surface.round(window, toggle, 8)
        local knob = window:Create("Frame", {
            Parent = toggle, Position = UDim2.fromOffset(17, 2), Size = UDim2.fromOffset(12, 12),
            BackgroundColor3 = theme.ContentColor, BorderSizePixel = 0, ZIndex = z + 3,
        })
        Surface.round(window, knob, 6)
        local title = Surface.label(window, card, entry.name, {
            Position = UDim2.fromOffset(10, 105), Size = UDim2.new(1, -20, 0, 20), TextSize = 14, ZIndex = z + 2,
        })
        -- Labels belong to the preview's theme too, independent of the theme currently applied.
        window.themeProperties[title].TextColor3 = nil
        title.TextColor3 = theme.ContentColor
        local description = Surface.label(window, card, entry.description, {
            Position = UDim2.fromOffset(10, 127), Size = UDim2.new(1, -20, 0, 18), TextSize = 10, TextTransparency = 0.25, ZIndex = z + 2,
        })
        window.themeProperties[description].TextColor3 = nil
        description.TextColor3 = theme.ContentColor
        local selected = Surface.label(window, mini, "✓", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -5, 0, 3), Size = UDim2.fromOffset(22, 22),
            TextSize = 20, ZIndex = z + 4, TextXAlignment = Enum.TextXAlignment.Center,
        })
        local hit = window:Create("TextButton", {
            Parent = card, Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
            Size = UDim2.fromScale(1, 1), ZIndex = z + 5,
        })
        owner:Connect(hit.MouseButton1Click, function() window:ChangeTheme(entry.id) end)
        table.insert(results, { id = entry.id, frame = card, stroke = stroke, selected = selected, hit = hit })
    end
    return results
end

local function selection(window, entries)
    for _, item in ipairs(entries) do
        local active = item.id == window.ThemeId
        item.stroke.Transparency, item.stroke.Thickness = active and 0 or 0.75, active and 2 or 1
        item.selected.Visible = active
    end
end

function Settings.openThemes(window)
    local modal = Surface.new(window, "Temas", "Toque numa prévia para aplicar. Sua escolha fica salva.", { width = 570, height = 650 })
    local scroll = window:Create("ScrollingFrame", {
        Parent = modal.content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollBarThickness = 3, ZIndex = 4012,
    }, { ScrollBarImageColor3 = "AccentColor" })
    local grid = window:Create("UIGridLayout", {
        Parent = scroll, CellPadding = UDim2.fromOffset(12, 12), CellSize = UDim2.new(0.5, -10, 0, 156), SortOrder = Enum.SortOrder.LayoutOrder,
    })
    window:Create("UIPadding", { Parent = scroll, PaddingTop = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 4) })
    modal.cards = cards(window, scroll, modal, Themes.catalog, 4013)
    function modal:RefreshTheme() selection(window, self.cards) end
    modal.onLayout = function(width)
        local columns = width < 420 and 1 or 2
        grid.CellSize = UDim2.new(1 / columns, columns == 1 and -12 or -13, 0, 156)
    end
    modal:Layout()
    modal:RefreshTheme()
    return modal
end

local function gallery(window, tab)
    local self = { window = window, tab = tab, name = "Temas com prévia", __type = "ThemeGallery", connections = {} }
    function self:Connect(signal, callback) return window:ConnectFor(self, signal, callback) end
    self.main = window:Create("Frame", {
        Name = "ThemeGallery", Parent = tab.tabPage, Size = UDim2.new(1, -20, 0, 600),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    Surface.label(window, self.main, "TEMAS COM PRÉVIA", { Position = UDim2.fromOffset(4, 0), TextSize = 13, ZIndex = 7 })
    self.gridFrame = window:Create("Frame", {
        Parent = self.main, BackgroundTransparency = 1, Position = UDim2.fromOffset(3, 32), Size = UDim2.new(1, -6, 1, -88), ZIndex = 7,
    })
    self.grid = window:Create("UIGridLayout", {
        Parent = self.gridFrame, CellPadding = UDim2.fromOffset(12, 12), CellSize = UDim2.new(0.5, -6, 0, 156), SortOrder = Enum.SortOrder.LayoutOrder,
    })
    local featured = {}
    for i = 1, 6 do featured[i] = Themes.catalog[i] end
    self.cards = cards(window, self.gridFrame, self, featured, 7)
    self.more = Surface.button(window, self.main, "Ver todos os temas · 12 prévias", {
        Position = UDim2.new(0, 3, 1, -44), Size = UDim2.new(1, -6, 0, 40), ZIndex = 12,
    })
    self:Connect(self.more.MouseButton1Click, function() Settings.openThemes(window) end)
    function self:Layout()
        local width = self.main.AbsoluteSize.X
        if width <= 0 then width = 500 end
        local columns = width < 380 and 1 or (width >= 690 and 3 or 2)
        self.grid.CellSize = UDim2.new(1 / columns, (columns - 1) * -12 / columns, 0, 156)
        self.main.Size = UDim2.new(1, -20, 0, 88 + math.ceil(#self.cards / columns) * 168 - 12)
    end
    self:Connect(self.main:GetPropertyChangedSignal("AbsoluteSize"), function() self:Layout() end)
    function self:_refreshTheme() selection(window, self.cards) end
    function self:_setShown(shown) self.main.Visible = shown end
    self:Layout()
    self:_refreshTheme()
    return tab:_register(self)
end

function Settings.attach(window)
    local tab = window.SettingsTab
    tab.name, tab.tabPage.Name = "Configurações", "Configurações"
    local first = #tab.elements + 1
    local mode, persistent = Preferences.storage()
    local status = tab:CreateText({ name = "Salvamento automático", text = mode })
    window.SaveStatus = { mode = mode, persistent = persistent, success = nil }
    function window:RefreshSaveStatus()
        if self.unloaded then return end
        local enabled = self.configuration.autoSave and "Ativado" or "Desativado"
        local result = self.SaveStatus.success == nil and "" or (self.SaveStatus.success and " · Alterações salvas" or " · Falha ao salvar")
        if self.PreferencesSaved == false then result ..= " · Preferências não salvas" end
        status:Set(enabled .. " · " .. mode .. result)
    end
    local save = window.Save
    function window:Save(...)
        local ok, result = pcall(save, self, ...)
        self.SaveStatus.success = ok and result == true
        self:RefreshSaveStatus()
        return self.SaveStatus.success
    end
    window.SaveConfig = window.Save
    window.AutoSaveToggle = tab:CreateToggle({ name = "Salvar escolhas automaticamente", value = window.configuration.autoSave, callback = function(value)
        window.configuration.autoSave = value
        Preferences.save(window)
        if value then window:Save() else window:RefreshSaveStatus() end
    end })
    window.AutoLoadToggle = tab:CreateToggle({ name = "Restaurar escolhas ao executar", value = window.configuration.autoLoad, callback = function(value)
        window.configuration.autoLoad = value
        Preferences.save(window)
    end })
    tab:CreateButton({ name = "Salvar agora", callback = function()
        window:Toast({ title = window:Save() and "Escolhas salvas" or "Não foi possível salvar" })
    end })
    tab:CreateButton({ name = "Ver meu perfil", callback = function() window:OpenProfile() end })
    window.ThemeGallery = gallery(window, tab)
    local added = {}
    for index = first, #tab.elements do table.insert(added, tab.elements[index]) end
    for index, element in ipairs(added) do tab:_moveElement(element, index) end
    window:RefreshSaveStatus()
    function window:OpenThemes() return Settings.openThemes(self) end
    function window:OpenSettings() if self._conexaoModal then self._conexaoModal:Close() end self.SettingsTab:Select() end
end

return Settings
