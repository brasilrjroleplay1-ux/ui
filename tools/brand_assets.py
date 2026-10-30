"""Embed the reviewed PNG catalogue. Runtime never downloads executor logos."""
from pathlib import Path
import base64,json
ROOT=Path(__file__).resolve().parents[1]

def generate():
    entries=json.loads((ROOT/'assets/executors/catalog.json').read_text())
    sources=[];rows=[]
    for entry in entries:
        key=entry['id']
        rows.append('    { id = '+json.dumps(key)+', name = '+json.dumps(entry['name'])+' },')
        if 'file' in entry:
            data=(ROOT/'assets/executors'/entry['file']).read_bytes()
            sources.append('    ["'+key+'"] = [['+base64.b64encode(data).decode()+']],')
    source='''--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Embedded artwork retains its owners' rights. See assets/README.md and catalogue sources.
local files = require(script.Parent.Parent.Gen2.utility.filesystem)
local variables = require(script.Parent.Parent.Gen2.utility.variables)
local path = require(script.Parent.Parent.Gen2.utility.path)
local Assets = {}
local sources = {
SOURCES
}
local cached, attempted = {}, {}
local function decode(value)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local lookup, bytes = {}, {}
    for index = 1, #alphabet do lookup[string.sub(alphabet, index, index)] = index - 1 end
    for index = 1, #value, 4 do
        local c, d = string.sub(value, index + 2, index + 2), string.sub(value, index + 3, index + 3)
        local number = lookup[string.sub(value, index, index)] * 262144
            + lookup[string.sub(value, index + 1, index + 1)] * 4096 + (lookup[c] or 0) * 64 + (lookup[d] or 0)
        table.insert(bytes, string.char(math.floor(number / 65536) % 256))
        if c ~= "=" then table.insert(bytes, string.char(math.floor(number / 256) % 256)) end
        if d ~= "=" then table.insert(bytes, string.char(number % 256)) end
    end
    return table.concat(bytes)
end
function Assets.get(id)
    if attempted[id] then return cached[id] end
    if not sources[id] then return nil end
    local env = _G
    if type(getgenv) == "function" then
        local ok, value = pcall(getgenv)
        if ok and type(value) == "table" then env = value end
    end
    local asset = getfenv().getcustomasset or getfenv().getsynasset or env.getcustomasset or env.getsynasset
    if type(asset) ~= "function" then return nil end
    attempted[id] = true
    local ok, result = pcall(function()
        local folder = variables.fileSystemManager:getAssetsFolder()
        local file = path.join(folder, id == "delta" and "delta-logo-256-v1.png" or id .. "-logo-v1.png")
        local png = decode(sources[id])
        if not files.isfile(file) or files.readfile(file) ~= png then
            files.ensureFolder(variables.fileSystemManager:getRootFolder())
            files.ensureFolder(folder)
            files.writefile(file, png)
        end
        return asset(file)
    end)
    if ok and type(result) == "string" and result ~= "" then cached[id] = result end
    return cached[id]
end
function Assets.delta() return Assets.get("delta") end
return Assets
'''.replace('SOURCES','\n'.join(sources))
    (ROOT/'ConexaoUI/Features/BrandAssets.luau').write_text(source)
    catalog='''--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Curated support list. Reported names do not establish binary integrity or safety.
local Catalog = {}
Catalog.entries = {
ROWS
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
'''.replace('ROWS','\n'.join(rows))
    (ROOT/'ConexaoUI/Features/ExecutorCatalog.luau').write_text(catalog)
if __name__=='__main__':generate()
