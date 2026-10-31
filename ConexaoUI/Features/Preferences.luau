--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local utility = script.Parent.Parent.Gen2.utility
local files = require(utility.filesystem)
local atomic = require(utility.persistenceWrite)
local paths = require(utility.persistencePaths)
local http = game:GetService("HttpService")
local Preferences = {}

function Preferences.load(configuration, name)
    local dir, configPath = paths.getConfigPath({ configuration = configuration, name = name })
    local path = configPath .. ".ui.json"
    local function read(file)
        local ok, value = pcall(function() return http:JSONDecode(files.readfile(file)) end)
        if ok and type(value) == "table" and value.version == 1 then return value end
    end
    local data = read(path) or read(atomic.tempPathFor(path)) or {}
    local state = { version = 1 }
    if type(data.theme) == "string" then state.theme = data.theme end
    if type(data.autoSave) == "boolean" then state.autoSave = data.autoSave end
    if type(data.autoLoad) == "boolean" then state.autoLoad = data.autoLoad end
    if type(data.autoSize) == "boolean" then state.autoSize = data.autoSize end
    if type(data.sidebarIconsOnly) == "boolean" then state.sidebarIconsOnly = data.sidebarIconsOnly end
    if type(data.notificationPosition) == "string" and (data.notificationPosition:lower() == "top" or data.notificationPosition:lower() == "bottom") then state.notificationPosition = data.notificationPosition:lower() end
    if ({ appearance = true, themes = true, saving = true, controls = true, performance = true })[data.settingsCategory] then state.settingsCategory = data.settingsCategory end
    if type(data.settingsSections) == "table" then
        state.settingsSections = {}
        for _, key in ipairs({ "appearance", "themes", "saving", "controls", "performance" }) do
            if type(data.settingsSections[key]) == "boolean" then state.settingsSections[key] = data.settingsSections[key] end
        end
    end
    if type(data.performance) == "table" then
        local p, clean = data.performance, {}
        for _, key in ipairs({ "lowGraphics", "disable3D", "hideUI", "showStats", "graphicsCollapsed", "frameCollapsed" }) do
            if type(p[key]) == "boolean" then clean[key] = p[key] end
        end
        if type(p.fpsCap) == "number" and p.fpsCap == p.fpsCap and p.fpsCap >= 30 and p.fpsCap <= 360 then clean.fpsCap = math.floor(p.fpsCap) end
        if ({ Leve = true, Equilibrado = true, ["Máximo"] = true })[p.mode] then clean.mode = p.mode end
        if ({ Preto = true, Grafite = true, Branco = true })[p.background] then clean.background = p.background end
        state.performance = clean
    end
    for _, key in ipairs({ "sizePercent", "transparency" }) do
        if type(data[key]) == "number" and data[key] == data[key] then state[key] = math.clamp(data[key], 0, 100) end
    end
    return state, dir, path
end

function Preferences.save(window)
    local state = window.UIPreferences
    state.autoSave, state.autoLoad = window.configuration.autoSave, window.configuration.autoLoad
    local ok = pcall(function()
        atomic.write(window._preferencesDir, window._preferencesPath, http:JSONEncode(state))
    end)
    window.PreferencesSaved = ok
    if window.RefreshSaveStatus then window:RefreshSaveStatus() end
    return ok
end

function Preferences.storage()
    if game:GetService("RunService"):IsStudio() then return "Sessão do Studio", false end
    local env = getfenv()
    for _, name in ipairs({ "writefile", "readfile", "isfile", "isfolder", "makefolder", "listfiles", "delfile", "delfolder" }) do
        if type(env[name]) ~= "function" then return "Arquivos indisponíveis", false end
    end
    return "Arquivos no dispositivo", true
end

return Preferences
