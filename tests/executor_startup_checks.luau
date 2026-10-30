-- Run inside the Roblox-service shim against the actual distributed source.
local createLibrary = function()
-- BUNDLE
end
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local run = game:GetService("RunService")
run.IsStudio = function() return false end
local created, originalNew = 0, Instance.new
Instance.new = function(class) created += 1 return originalNew(class) end
local originalService = game.GetService
local serviceCalls = {}
game.GetService = function(self, name)
    table.insert(serviceCalls, name)
    return originalService(self, name)
end
for _, name in ipairs({ "Not Listed", "Delta Clone", "Delta Runtime", "Dеlta", "Codex", "Velocity" }) do
    _G.identifyexecutor = function() return name end
    created, serviceCalls = 0, {}
    local ok, message = pcall(createLibrary)
    check(not ok and tostring(message):find("executor não suportado", 1, true), "the initial loader rejects " .. name)
    check(created == 0 and #serviceCalls == 1 and serviceCalls[1] == "RunService", "the rejected loader does not initialize Gen2 services or create instances")
end
_G.identifyexecutor = nil
check(not pcall(createLibrary), "the initial loader rejects missing identification APIs")
_G.identifyexecutor = function() error("unavailable identification") end
check(not pcall(createLibrary), "the initial loader rejects failed identification")
for _, name in ipairs({ "Delta", "Wave", "Xeno", "Solara", "  DELTA  " }) do
    _G.identifyexecutor = function() return name, "1.0" end
    local ok, library = pcall(createLibrary)
    check(ok and library.Version == "3.7.0" and #library.SupportedExecutors == 4, "the loader admits an explicitly permitted name: " .. name)
end
_G.identifyexecutor = nil
_G.getexecutorname = function() return "Wave", "2.0" end
check(pcall(createLibrary), "getexecutorname remains a supported identification API")
_G.getexecutorname = nil
run.IsStudio = function() return true end
check(pcall(createLibrary), "Studio has an explicit development exception")
Instance.new, game.GetService = originalNew, originalService
print("PASS: " .. checks .. " executor startup checks against the real bundle")
