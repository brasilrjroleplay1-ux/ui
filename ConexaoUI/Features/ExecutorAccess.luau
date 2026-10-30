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
    local studio = game:GetService("RunService"):IsStudio()
    local identity = { name = "Não identificado", environment = "Roblox", identified = false }
    local scopes, seen = {}, {}
    local function scope(value)
        if type(value) == "table" and not seen[value] then seen[value] = true table.insert(scopes, value) end
    end
    scope(_G)
    scope(getfenv())
    if type(getgenv) == "function" then
        local ok, value = pcall(getgenv)
        if not ok or type(value) ~= "table" then identity.failure = "environment" return identity end
        scope(value)
    end
    local functions, observed = {}, {}
    for _, name in ipairs({ "identifyexecutor", "getexecutorname" }) do
        for _, env in ipairs(scopes) do
            local ok, fn = pcall(function() return env[name] end)
            if not ok or (fn ~= nil and type(fn) ~= "function") then identity.failure = "api" return identity end
            if fn and not observed[fn] then
                observed[fn] = true
                table.insert(functions, fn)
            end
        end
    end
    if #functions == 0 and studio then return { name = "Roblox Studio", environment = "Roblox Studio", identified = false } end
    local reports = {}
    for _, fn in ipairs(functions) do
        local ok, name, version = pcall(fn)
        if not ok or type(name) ~= "string" or name == "" then identity.failure = "api" return identity end
        local safeVersion = type(version) == "string" and #version <= 128 and not version:find("%c") and version or nil
        table.insert(reports, { name = name, version = safeVersion })
    end
    if #reports > 0 then
        identity.name, identity.version, identity.identified, identity.reports = reports[1].name, reports[1].version, true, reports
    end
    return identity
end

function Access.requireSupported()
    local identity = Access.identify()
    local allowed, reason, canonical = Policy.check(identity, rules)
    if not allowed then
        local messages = { conflicting = "As APIs informaram executores diferentes.", identification_failed = "Não foi possível validar as APIs de identificação.", unidentified = "O cliente não forneceu identificação válida.", not_permitted = "O nome informado não está na lista permitida." }
        error(denial .. " " .. (messages[reason] or "Identificação recusada."), 0)
    end
    identity.reportedName, identity.name, identity.support = identity.name, canonical, reason
    return identity
end

function Access.names() return table.clone(names) end
return table.freeze(Access)
