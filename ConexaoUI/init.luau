--!nonstrict
-- Conexão UI 3.0 — integration layer for the pinned Rayfield Gen2 fork.
-- SPDX-License-Identifier: MPL-2.0
local Gen2 = require(script.Gen2)

export type Window = Gen2.Window
export type WindowProps = Gen2.WindowProps
export type Theme = Gen2.Theme
export type Tab = Gen2.Tab

local Library = { Version = "3.0.0", UpstreamVersion = "1.2.1", Windows = {} }
local env = _G
if type(getgenv) == "function" then
    local ok, value = pcall(getgenv)
    if ok and type(value) == "table" then env = value end
end
if type(env.__CONEXAO_UI_V3_WINDOWS) ~= "table" then env.__CONEXAO_UI_V3_WINDOWS = {} end
local windows = env.__CONEXAO_UI_V3_WINDOWS

local function executor()
    for _, name in ipairs({ "identifyexecutor", "getexecutorname" }) do
        local fn = env[name] or getfenv()[name]
        if type(fn) == "function" then
            local ok, value = pcall(fn)
            if ok and type(value) == "string" and value ~= "" then return value end
        end
    end
    return game:GetService("RunService"):IsStudio() and "Roblox Studio" or "Cliente Roblox"
end

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
    for _, kind in ipairs({ "Button", "Toggle", "Slider", "Dropdown", "Input", "Keybind", "ColorPicker", "Text", "Progress", "Console", "Stat", "Divider", "Section", "Group" }) do
        local method = host["Create" .. kind]
        if method then
            host["Create" .. kind] = function(self, props)
                local mapped = properties(props)
                if kind == "ColorPicker" and mapped.color == nil and mapped.Color == nil then mapped.color = mapped.value or mapped.Value end
                local control = method(self, mapped)
                if control then
                    if kind == "Group" then adaptHost(control) end
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
    local p = type(options) == "table" and table.clone(options) or {}
    p.name = p.name or p.Name or p.Title or "Conexão UI"
    p.showName = p.showName or p.ShowName or p.name
    if p.sidebarLayout == nil and p.SidebarLayout == nil then p.sidebarLayout = true end
    p.profile = p.profile or p.Profile or executor()
    local cfg = table.clone(p.configuration or p.Configuration or {})
    local old = p.Config or {}
    if cfg.autoSave == nil then cfg.autoSave = cfg.AutoSave end
    if cfg.autoLoad == nil then cfg.autoLoad = cfg.AutoLoad end
    if cfg.autoSave == nil then cfg.autoSave = old.Enabled ~= false end
    if cfg.autoLoad == nil then cfg.autoLoad = true end
    cfg.fileName = cfg.fileName or cfg.FileName or old.Name or ((p.Id or p.name) .. "-" .. tostring(game.PlaceId))
    cfg.customFolder = cfg.customFolder or cfg.CustomFolder
    p.configuration = cfg
    local id = tostring(p.Id or p.name)
    if windows[id] and not windows[id].unloaded then windows[id]:Unload() end
    local window = Gen2:CreateWindow(p)
    windows[id] = window
    self.Windows[id] = window
    window.SettingsTab = window.rfSettings
    window.screenGui.Name = "ConexaoUI3_" .. id
    local createTab = window.CreateTab
    function window:CreateTab(props, icon)
        if type(props) == "string" then props = { name = props, icon = icon } end
        return adaptHost(createTab(self, props))
    end
    local unload = window.Unload
    function window:Unload()
        if self.unloaded then return end
        if self.configuration.autoSave and (not self.configuration.autoLoad or self._autoLoaded) then pcall(self.Save, self) end
        unload(self)
        if windows[id] == self then windows[id] = nil end
        if Library.Windows[id] == self then Library.Windows[id] = nil end
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
return Library
