--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Runtime identification catalogue; names are not compatibility guarantees.
local Catalog = {}
Catalog.entries = {
    { id = "potassium", name = "Potassium" },
    { id = "matcha", name = "Matcha" },
    { id = "xeno", name = "Xeno" },
    { id = "photon", name = "Photon" },
    { id = "dx9warev2", name = "DX9WARE V2" },
    { id = "sirhurt", name = "SirHurt" },
    { id = "seliware", name = "Seliware" },
    { id = "volt", name = "Volt" },
    { id = "velocity", name = "Velocity" },
    { id = "solara", name = "Solara" },
    { id = "matrixhub", name = "Matrix Hub" },
    { id = "wave", name = "Wave" },
    { id = "delta", name = "Delta" },
    { id = "volcano", name = "Volcano" },
    { id = "serotonin", name = "Serotonin" },
    { id = "melatonin", name = "Melatonin" },
    { id = "synapsez", name = "Synapse Z" },
    { id = "macsploit", name = "MacSploit" },
    { id = "vegax", name = "Vega X" },
    { id = "opiumware", name = "Opiumware" },
    { id = "lynx", name = "Lynx" },
    { id = "madium", name = "Madium" },
    { id = "lumen", name = "Lumen" },
    { id = "real", name = "Real" },
    { id = "axis", name = "Axis" },
    { id = "isaeva", name = "Isaeva" },
    { id = "madius", name = "Madius" },
    { id = "lucid", name = "Lucid" },
    { id = "codex", name = "Codex" },
}
function Catalog.key(name) return string.lower(tostring(name or "")):gsub("[^%w]", "") end
function Catalog.find(name)
    local key, best = Catalog.key(name), nil
    for _, entry in ipairs(Catalog.entries) do
        if key == entry.id or string.sub(key, 1, #entry.id) == entry.id then
            if not best or #entry.id > #best.id then best = entry end
        end
    end
    return best
end
return Catalog
