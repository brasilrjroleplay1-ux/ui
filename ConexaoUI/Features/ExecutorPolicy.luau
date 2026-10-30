--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Explicit support policy. Reported names do not establish binary integrity or safety.
local Policy = {}

local function key(name)
    if type(name) ~= "string" then return nil end
    local normalized = string.lower(name):gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")
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
    return rules
end

function Policy.check(identity, rules)
    assert(type(rules) == "table" and type(rules.names) == "table", "Compile the executor policy first")
    if type(identity) ~= "table" then return false, "unidentified" end
    if identity.environment == "Roblox Studio" and rules.allowStudio then return true, "studio", "Roblox Studio" end
    local normalized = key(identity.name)
    if identity.identified ~= true or not normalized then return false, "unidentified" end
    local permitted = rules.names[normalized]
    if permitted then return true, "permitted", permitted end
    return false, "not_permitted"
end

return Policy
