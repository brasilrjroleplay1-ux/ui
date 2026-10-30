-- Exercise privacy defaults and legacy persisted settings against the real public bundle.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local w = UI:CreateWindow({ Id = "Privacy373", configuration = { autoSave = false, autoLoad = false } })
check(not w._sia and w.settings.usageAnalytics == false, "the collector cannot start during construction")
for _, element in ipairs(w.SettingsTab.elements) do
    check(element.name ~= "Usage analytics", "settings do not offer a telemetry opt-in control")
end
local savedGlobal = _G.RAYFIELD_ANALYTICS
_G.RAYFIELD_ANALYTICS = true
w.settings.usageAnalytics = true
local run = game:GetService("RunService")
local studio = run.IsStudio
run.IsStudio = function() return false end
w:_siaStart({ name = "Should not collect" })
run.IsStudio = studio
check(not w._sia and w.settings.usageAnalytics == false, "even explicit startup with a legacy enabled flag cannot activate SIA")
check(_G.RAYFIELD_ANALYTICS == true, "the privacy guard does not rewrite another library's global preference")
w.settings.usageAnalytics = true
check(w:SaveSettings(), "ordinary interface preferences still save")
check(w.settings.usageAnalytics == false, "saving forces the telemetry preference off")
local files = game:GetService("ReplicatedStorage"):FindFirstChild("Filesystem")
local settings
for _, node in ipairs(files:GetDescendants()) do
    if node:IsA("StringValue") and node.Name == "conexao.rfld" then settings = node break end
end
check(settings ~= nil, "the test found the real native settings file")
local http = game:GetService("HttpService")
check(http:JSONDecode(settings.Value).usageAnalytics == false, "the serialized settings do not retain a telemetry opt-in")
settings.Value = http:JSONEncode({ usageAnalytics = true, showProfile = false })
check(w:LoadSettings() and w.settings.usageAnalytics == false and w.settings.showProfile == false, "old enabled settings cannot restore analytics while unrelated preferences still load")
w:Unload()
settings.Value = http:JSONEncode({ usageAnalytics = true, showProfile = true })
w = UI:CreateWindow({ Id = "Privacy373", configuration = { autoSave = false, autoLoad = false } })
check(not w._sia and w.settings.usageAnalytics == false and w.settings.showProfile == true, "reexecution with an old telemetry opt-in also keeps the collector disabled")
w:Unload()
_G.RAYFIELD_ANALYTICS = savedGlobal
check(#w.connections == 0 and #w.instances == 0, "privacy wrappers preserve window cleanup")
print("PASS: " .. checks .. " privacy and legacy settings checks")
