--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Namespacing, not access control against the host. Sharing is an explicit per-account choice.
local utility = script.Parent.Parent.Gen2.utility
local files = require(utility.filesystem)
local atomic = require(utility.persistenceWrite)
local paths = require(utility.persistencePaths)
local path = require(utility.path)
local http = game:GetService("HttpService")
local Storage = {}
function Storage.prepare(configuration, name)
    local player = game:GetService("Players").LocalPlayer
    local id = player and player.UserId
    local studio = game:GetService("RunService"):IsStudio()
    assert(type(id) == "number" and id == id and math.abs(id) < 9007199254740992 and id % 1 == 0 and (id > 0 or studio), "Conexão Studio: aguarde a identificação da conta Roblox antes de criar a janela.")
    local account = string.format("%.0f", id)
    local folder = path.sanitizeFolder(configuration.customFolder or ""):gsub("/+$", "")
    local file = path.sanitizeFile(configuration.fileName or name)
    if file == "" then file = "Configuration" end
    local suffix = (folder ~= "" and folder .. "/" or "") .. file
    local private = "Accounts/" .. account .. "/" .. suffix
    local shared = "Shared/" .. suffix
    local dir, base = paths.getConfigPath({ configuration = { customFolder = private, fileName = file }, name = name })
    local meta = base .. ".scope.json"
    local function read(filePath)
        local ok, data = pcall(function() return http:JSONDecode(files.readfile(filePath)) end)
        if ok and type(data) == "table" and data.version == 1 and type(data.shareAcrossAccounts) == "boolean" then return data end
    end
    -- A failed or corrupt opt-in must not enable sharing from an uncommitted temp file.
    local saved = read(meta)
    local enabled = saved and saved.shareAcrossAccounts
    if not saved then
        local requested = configuration.shareAcrossAccounts
        if requested == nil then requested = configuration.ShareAcrossAccounts end
        enabled = requested == true
    end
    configuration.customFolder = enabled and shared or private
    configuration.fileName = file
    return { userId = id, username = player.Name, shared = enabled, nextShared = enabled,
        privateFolder = private, sharedFolder = shared, folder = configuration.customFolder, metadataDir = dir, metadataPath = meta }
end
function Storage.attach(window, scope)
    window.ConfigurationScope = scope
    function window:SetSharedConfiguration(enabled)
        assert(type(enabled) == "boolean", "Use true ou false para compartilhar configurações.")
        if self.unloaded then return false end
        local ok = pcall(function()
            atomic.write(scope.metadataDir, scope.metadataPath, http:JSONEncode({ version = 1, shareAcrossAccounts = enabled }))
        end)
        if ok then
            scope.nextShared = enabled
            if self.ShareAcrossAccountsToggle then self.ShareAcrossAccountsToggle:Set(enabled, true) end
            if self.RefreshScopeStatus then self:RefreshScopeStatus() end
        end
        return ok
    end
end
return Storage
