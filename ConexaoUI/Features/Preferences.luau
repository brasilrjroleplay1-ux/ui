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
