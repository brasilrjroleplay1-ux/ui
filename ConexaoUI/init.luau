--!nonstrict
-- Conexão UI 3.6 — integration layer for the pinned Rayfield Gen2 fork.
-- SPDX-License-Identifier: MPL-2.0
local ExecutorAccess = require(script.Features.ExecutorAccess)
ExecutorAccess.requireSupported()
local Gen2 = require(script.Gen2)
local DropdownPanel = require(script.Features.Dropdown)
local Profile = require(script.Features.Profile)
local Themes = require(script.Features.Themes)
local Preferences = require(script.Features.Preferences)
local Settings = require(script.Features.Settings)
local Responsive = require(script.Features.Responsive)
local Appearance = require(script.Features.Appearance)
local Scrolling = require(script.Features.Scrolling)
local Startup = require(script.Features.Startup)
local Localization = require(script.Features.Localization)
local Session = require(script.Features.Session)
local BrandIcon = require(script.Features.BrandIcon)
local Controls = require(script.Features.ControlLayout)
local Header = require(script.Features.Header)
local Entrance = require(script.Features.Entrance)
local Shell = require(script.Features.Shell)
local Friends = require(script.Features.Friends)

export type Window = Gen2.Window & {
    OpenSettings: (self: any) -> (),
    OpenProfile: (self: any) -> any,
    OpenHome: (self: any) -> any,
    GetSessionStats: (self: any) -> any,
    GetFriendStats: (self: any) -> any,
    RefreshFriends: (self: any, force: boolean?) -> (),
    CloseProfile: (self: any) -> (),
    OpenThemes: (self: any) -> any,
    SettingsTab: Gen2.Tab,
    ThemeId: string?,
    RefreshSize: (self: any) -> UDim2,
}
export type WindowProps = Gen2.WindowProps & { Id: string?, rememberTheme: boolean? }
export type Theme = Gen2.Theme
export type Tab = Gen2.Tab

local Library = { Version = "3.6.2", UpstreamVersion = "1.2.1", Windows = {}, Themes = Themes.catalog, SupportedExecutors = ExecutorAccess.names() }
local env = _G
if type(getgenv) == "function" then
    local ok, value = pcall(getgenv)
    if ok and type(value) == "table" then env = value end
end
if type(env.__CONEXAO_UI_V3_WINDOWS) ~= "table" then env.__CONEXAO_UI_V3_WINDOWS = {} end
local windows = env.__CONEXAO_UI_V3_WINDOWS

local function properties(value)
    local p = type(value) == "table" and table.clone(value) or {}
    if p.value == nil and p.Value == nil and p.Default ~= nil then p.value = p.Default end
    if p.flag == nil and p.Flag == nil and p.Id then p.flag = p.Id end
    if p.range == nil and p.Range == nil and p.Min ~= nil and p.Max ~= nil then p.range = { p.Min, p.Max } end
    if p.multiSelect == nil and p.MultiSelect == nil and p.Multi ~= nil then p.multiSelect = p.Multi end
    if p.forgetState == nil and p.ForgetState == nil and p.Persistent == false then p.forgetState = true end
    return p
end

local function adaptHost(host)
    if host._conexaoAdapted then return host end
    host._conexaoAdapted = true
    if host.tabPageLayout then Scrolling.tab(host) end
    if host.Select then
        local select = host.Select
        function host:Select(...)
            local panel = self.window._conexaoPanel
            if panel and panel.tab ~= self then panel:Close(false) end
            local result = select(self, ...)
            if self.window._refreshProfileCard then self.window:_refreshProfileCard() end
            return result
        end
    end
    for _, element in ipairs(host.elements or {}) do
        Controls.attach(element)
        if element.__type == "Dropdown" then DropdownPanel.attach(element)
        elseif element.__type == "Group" then adaptHost(element) end
    end
    for _, kind in ipairs({ "Button", "Toggle", "Slider", "Dropdown", "Input", "Keybind", "ColorPicker", "Text", "Progress", "Console", "Stat", "Divider", "Section", "Group" }) do
        local method = host["Create" .. kind]
        if method then
            host["Create" .. kind] = function(self, props)
                local mapped = properties(props)
                if kind == "ColorPicker" and mapped.color == nil and mapped.Color == nil then mapped.color = mapped.value or mapped.Value end
                local control = method(self, mapped)
                if control then
                    Controls.attach(control)
                    if kind == "Group" then adaptHost(control) end
                    if kind == "Dropdown" then DropdownPanel.attach(control, mapped) end
                    if control.Set then
                        control.SetValue = function(c, value) return c:Set(value) end
                        control.GetValue = function(c)
                            if kind == "ColorPicker" then return "#" .. c.value:ToHex() end
                            if kind == "Dropdown" and not c.multiSelect then return c.value[1] end
                            return type(c.value) == "table" and table.clone(c.value) or c.value
                        end
                    end
                end
                return control
            end
        end
    end
    host.CreateTextbox = host.CreateInput
    host.CreateProgressBar = host.CreateProgress
    return host
end

function Library:CreateWindow(options)
    local executorInfo = ExecutorAccess.requireSupported()
    local p = type(options) == "table" and table.clone(options) or {}
    Localization.configure(p)
    p.name = p.name or p.Name or p.Title or "Conexão UI"
    p.showName = p.showName or p.ShowName or p.name
    if p.sidebarLayout == nil and p.SidebarLayout == nil then p.sidebarLayout = true end
    p.profile = p.profile or p.Profile or executorInfo.name
    local cfg = table.clone(p.configuration or p.Configuration or {})
    local old = p.Config or {}
    if cfg.autoSave == nil then cfg.autoSave = cfg.AutoSave end
    if cfg.autoLoad == nil then cfg.autoLoad = cfg.AutoLoad end
    cfg.fileName = cfg.fileName or cfg.FileName or old.Name or ((p.Id or p.name) .. "-" .. tostring(game.PlaceId))
    cfg.customFolder = cfg.customFolder or cfg.CustomFolder
    local preferences, preferencesDir, preferencesPath = Preferences.load(cfg, p.name)
    if cfg.autoSave == nil then cfg.autoSave = if old.Enabled ~= nil then old.Enabled ~= false elseif preferences.autoSave ~= nil then preferences.autoSave else true end
    if cfg.autoLoad == nil then cfg.autoLoad = if preferences.autoLoad ~= nil then preferences.autoLoad else true end
    local requestedTheme = p.theme or p.Theme or "conexao"
    local themeId = if type(requestedTheme) == "string" then requestedTheme:lower() else nil
    if p.rememberTheme ~= false and type(requestedTheme) ~= "table" and Themes.entry(preferences.theme) then themeId = preferences.theme end
    p.theme = Themes.resolve(themeId) or requestedTheme
    p.configuration = cfg
    local introduction
    p.startup = function()
        introduction = Startup.new(p.theme, self.Version)
        return introduction
    end
    local id = tostring(p.Id or p.name)
    if windows[id] and not windows[id].unloaded then windows[id]:Unload() end
    local window = Gen2:CreateWindow(p)
    windows[id] = window
    self.Windows[id] = window
    window.SettingsTab = window.rfSettings
    window.UIPreferences, window._preferencesDir, window._preferencesPath = preferences, preferencesDir, preferencesPath
    window.ThemeId = themeId
    window.screenGui.Name = "ConexaoUI3_" .. id
    -- Install the first-open hooks before adapters that may yield while measuring fonts.
    Shell.attach(window)
    Header.attach(window, self.Version)
    Entrance.attach(window)
    local createTab = window.CreateTab
    function window:CreateTab(props, icon)
        if type(props) == "string" then props = { name = props, icon = icon } end
        local tab = adaptHost(createTab(self, props))
        self:_applyRailWidth()
        if not tab.neglectSelector then
            local firstUserTab = true
            for _, other in ipairs(self.tabs) do
                if other ~= tab and other ~= self.SettingsTab and other ~= self.HomeTab and other ~= self.ProfileTab and not other.neglectSelector then firstUserTab = false break end
            end
            if firstUserTab then tab:Select(true) end
        end
        return tab
    end
    adaptHost(window.SettingsTab)
    local changeTheme = window.ChangeTheme
    function window:ChangeTheme(theme)
        local resolved = Themes.resolve(theme) or (type(theme) == "table" and table.clone(theme))
        if resolved then resolved.ElementTransparency = (self.UIPreferences.transparency or 0) / 100 end
        changeTheme(self, resolved or theme)
        self.ThemeId = type(theme) == "string" and theme:lower() or nil
        if self.ApplyTransparency then self:ApplyTransparency() end
        if self.RefreshShellTheme then self:RefreshShellTheme() end
        if p.rememberTheme ~= false then
            self.UIPreferences.theme = self.ThemeId
            Preferences.save(self)
        end
        if self.ThemeGallery then self.ThemeGallery:_refreshTheme() end
        if self._conexaoPanel and self._conexaoPanel.RefreshTheme then self._conexaoPanel:RefreshTheme() end
    end
    Profile.attach(window, executorInfo, self.Version)
    Responsive.attach(window)
    Appearance.attach(window)
    Settings.attach(window)
    Session.attach(window)
    Friends.attach(window)
    Scrolling.attachWindow(window)
    window.Introduction = introduction
    if introduction then introduction:Ready() end
    if window.searchAction then
        local search = window.searchAction.callback
        window.searchAction.callback = function(...)
            if window._conexaoPanel then window._conexaoPanel:Close() end
            return search(...)
        end
    end
    local hide = window.Hide
    function window:Hide(...)
        if self._conexaoPanel then self._conexaoPanel:Close() end
        return hide(self, ...)
    end
    local unload = window.Unload
    function window:Unload()
        if self.unloaded then return end
        if introduction then introduction:Cancel() end
        if self._conexaoPanel then self._conexaoPanel:Close() end
        if self.configuration.autoSave and (not self.configuration.autoLoad or self._autoLoaded) then pcall(self.Save, self) end
        unload(self)
        if windows[id] == self then windows[id] = nil end
        if Library.Windows[id] == self then Library.Windows[id] = nil end
        self.ProfileTab, self.ProfilePage, self._profilePreviousTab = nil, nil, nil
        self.HomeTab, self.HomePage, self._homePreviousTab = nil, nil, nil
    end
    window.Destroy = window.Unload
    window.SaveConfig = window.Save
    window.SelectTab = function(_, tab) tab:Select() end
    window:Connect(window.screenGui.Destroying, function() if not window.unloaded then window:Unload() end end)
    return window
end

function Library:Destroy()
    for _, window in pairs(table.clone(self.Windows)) do window:Unload() end
end
function Library:RegisterExecutorIcon(name, icon, aliases)
    return BrandIcon.register(name, icon, aliases)
end
return Library
