--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Support selection only: the host controls its reported name and cannot be audited here.
local Policy = require(script.Parent.ExecutorPolicy)
local Catalog = require(script.Parent.ExecutorCatalog)
local Access = {}
local rules = Policy.compile(Catalog.entries, { allowStudio = true })
local names = {}
for _, entry in ipairs(Catalog.entries) do table.insert(names, entry.name) end
local denial = "Conexão Studio: executor não suportado. Permitidos: " .. table.concat(names, ", ") .. "."

function Access.identify()
    if game:GetService("RunService"):IsStudio() then
        return { name = "Roblox Studio", environment = "Roblox Studio", identified = false }
    end
    local env = _G
    if type(getgenv) == "function" then
        local ok, value = pcall(getgenv)
        if ok and type(value) == "table" then env = value end
    end
    for _, name in ipairs({ "identifyexecutor", "getexecutorname" }) do
        local fn = env[name] or getfenv()[name]
        if type(fn) == "function" then
            local ok, value, version = pcall(fn)
            if ok and type(value) == "string" and value ~= "" then
                return { name = value, version = type(version) == "string" and version or nil, environment = "Roblox", identified = true }
            end
        end
    end
    return { name = "Não identificado", environment = "Roblox", identified = false }
end

function Access.requireSupported()
    local identity = Access.identify()
    local allowed, reason, canonical = Policy.check(identity, rules)
    if not allowed then error(denial, 0) end
    identity.reportedName, identity.name, identity.support = identity.name, canonical, reason
    return identity
end

function Access.names() return table.clone(names) end
return Access
