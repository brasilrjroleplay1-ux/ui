--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Explicit support policy. Reported names do not establish binary integrity or safety.
local Policy = {}

local function key(name)
    if type(name) ~= "string" or #name > 64 or name:find("%c") then return nil end
    local normalized = string.lower(name):gsub(" +", " "):gsub("^ ", ""):gsub(" $", "")
    return normalized ~= "" and normalized or nil
end

function Policy.compile(entries, options)
    assert(type(entries) == "table", "An explicit list of permitted executors is required")
    local rules = { names = {}, allowStudio = options ~= nil and options.allowStudio == true }
    local function add(name, canonical)
        local normalized = key(name)
        assert(normalized, "Executor names and aliases must be non-empty strings")
        assert(not rules.names[normalized], "Duplicate executor name or alias: " .. name)
        rules.names[normalized] = canonical
    end
    for _, entry in ipairs(entries) do
        if type(entry) == "string" then
            add(entry, entry)
        else
            assert(type(entry) == "table" and key(entry.name), "Use a name or a record containing name and aliases")
            assert(entry.aliases == nil or type(entry.aliases) == "table", "Aliases must be a list")
            add(entry.name, entry.name)
            for _, alias in ipairs(entry.aliases or {}) do add(alias, entry.name) end
        end
    end
    table.freeze(rules.names)
    return table.freeze(rules)
end

function Policy.check(identity, rules)
    assert(type(rules) == "table" and type(rules.names) == "table", "Compile the executor policy first")
    if type(identity) ~= "table" then return false, "unidentified" end
    if identity.failure then return false, "identification_failed" end
    if identity.environment == "Roblox Studio" and rules.allowStudio and identity.identified ~= true and identity.reports == nil then return true, "studio", "Roblox Studio" end
    local normalized = key(identity.name)
    if identity.identified ~= true or not normalized then return false, "unidentified" end
    local permitted = rules.names[normalized]
    if permitted then
        if identity.reports ~= nil then
            if type(identity.reports) ~= "table" or #identity.reports == 0 then return false, "unidentified" end
            for _, report in ipairs(identity.reports) do
                local reported = type(report) == "table" and key(report.name)
                local match = reported and rules.names[reported]
                if not match then return false, "not_permitted" end
                if match ~= permitted then return false, "conflicting" end
            end
        end
        return true, "permitted", permitted
    end
    return false, "not_permitted"
end

return table.freeze(Policy)
