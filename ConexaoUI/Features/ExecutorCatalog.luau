--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Curated support list. Reported names do not establish binary integrity or safety.
local Catalog = {}
Catalog.entries = {
    { id = "delta", name = "Delta" },
    { id = "wave", name = "Wave" },
    { id = "xeno", name = "Xeno" },
    { id = "solara", name = "Solara" },
}
function Catalog.key(name) return string.lower(tostring(name or "")):gsub("[^%w]", "") end
function Catalog.find(name)
    local key = Catalog.key(name)
    for _, entry in ipairs(Catalog.entries) do
        if key == entry.id then return entry end
    end
    return nil
end
return Catalog
