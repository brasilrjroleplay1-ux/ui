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
    check(ok and library.Version == "3.8.0" and #library.SupportedExecutors == 4, "the loader admits an explicitly permitted name: " .. name)
end
_G.identifyexecutor = nil
_G.getexecutorname = function() return "Wave", "2.0" end
check(pcall(createLibrary), "getexecutorname remains a supported identification API")
_G.getexecutorname = nil
for _, pair in ipairs({ { "Delta", "Wave" }, { "Delta", "Unknown" }, { "Unknown", "Delta" } }) do
    _G.identifyexecutor = function() return pair[1] end
    _G.getexecutorname = function() return pair[2] end
    created, serviceCalls = 0, {}
    check(not pcall(createLibrary), "conflicting identity reports are denied")
    check(created == 0 and #serviceCalls == 1, "conflict is rejected before Gen2 initialization")
end
_G.identifyexecutor = function() error("broken API") end
_G.getexecutorname = function() return "Delta" end
check(not pcall(createLibrary), "a failed primary API cannot fall through to a permitted fallback")
_G.identifyexecutor = function() return "Delta" end
_G.getexecutorname = function() return nil end
check(not pcall(createLibrary), "an available API returning no identity causes denial")
_G.getexecutorname = function() return "  DELTA  " end
check(pcall(createLibrary), "consistent reports admit a listed executor")
_G.identifyexecutor = nil
_G.getexecutorname = nil
local getEnvironment = getgenv
_G.identifyexecutor = function() return "Delta" end
getgenv = function() return { identifyexecutor = function() return "Wave" end } end
check(not pcall(createLibrary), "an environment-specific identification conflict is denied")
getgenv = function() error("private runtime detail") end
local environmentOK, environmentError = pcall(createLibrary)
check(not environmentOK and not tostring(environmentError):find("private runtime detail", 1, true), "failed environment APIs are denied without exposing raw exception text")
getgenv = function() return "invalid" end
check(not pcall(createLibrary), "a malformed executor environment is denied")
getgenv = getEnvironment
local calls = 0
local identifyOnce = function() calls += 1 return "Delta" end
_G.identifyexecutor, _G.getexecutorname = identifyOnce, identifyOnce
check(pcall(createLibrary) and calls == 1, "the same API function is invoked only once even when exposed under multiple names")
_G.getexecutorname = nil
_G.identifyexecutor = function() return "Delta" end
local cachedLibrary = createLibrary()
table.insert(cachedLibrary.SupportedExecutors, "Unknown")
_G.identifyexecutor = function() return "Unknown" end
created, serviceCalls = 0, {}
check(not pcall(cachedLibrary.CreateWindow, cachedLibrary, { name = "Denied" }), "CreateWindow rechecks identity even after a library was admitted")
check(created == 0 and #serviceCalls == 1, "a denied CreateWindow cannot initialize the interface or preferences")
check(not pcall(createLibrary), "editing the public support list does not widen private admission rules")
_G.identifyexecutor = nil
run.IsStudio = function() return true end
check(pcall(createLibrary), "Studio has an explicit development exception")
_G.identifyexecutor = function() return "Unknown" end
check(not pcall(createLibrary), "Studio does not bypass an explicit unknown executor report")
_G.identifyexecutor = nil
Instance.new, game.GetService = originalNew, originalService
print("PASS: " .. checks .. " executor startup checks against the real bundle")
