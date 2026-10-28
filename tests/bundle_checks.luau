-- Runs against the actual generated bundle inside the upstream Roblox-service shim.
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local UI = (function()
-- BUNDLE
end)()
check(UI.Version == "3.0.0", "new entry point is bundled")
local w = UI:CreateWindow({ Id = "BundleTest", name = "Conexão", theme = "amethyst" })
check(w.layout.mode == "sidebar", "profile layout is automatic")
check(w.configuration.autoSave and w.configuration.autoLoad, "configuration works without additional setup")
check(w.profileText == "Roblox Studio", "profile subtitle comes from the runtime")
check(w.settings.usageAnalytics == false, "the fork starts with analytics disabled")
check(w.SettingsTab == w.rfSettings, "settings are provided by the actual Gen2 implementation")
local tab = w:CreateTab({ name = "Main", icon = 93364949241311 })
local toggle = tab:CreateToggle({ Name = "Enabled", Id = "enabled", Default = true })
local slider = tab:CreateSlider({ Name = "Amount", Id = "amount", Min = 0, Max = 100, Default = 25 })
local drop = tab:CreateDropdown({ name = "Choice", flag = "choice", options = { "One", "Two" }, value = "One" })
local multi = tab:CreateDropdown({ name = "Many", flag = "many", options = { "A", "B", "C" }, multiSelect = true, value = { "A" } })
check(toggle.value == true and slider.value == 25, "supported old property aliases map into real Gen2 controls")
check(toggle.window == w and slider.__type == "Slider" and drop.__type == "Dropdown", "the controls are Gen2 objects")
toggle:Set(false) slider:Set(70) drop:Set("Two") multi:Set({ "B", "C" })
local input = tab:CreateInput({ name = "Alias", flag = "alias", value = "Creator" })
local color = tab:CreateColorPicker({ name = "Color", Id = "color", Default = "#112233" })
check(color:GetValue() == "#112233", "color aliases return the chosen value")
check(w:Save(), "actual persistence saves through the Studio file adapter")
w.configuration.autoSave = false
toggle:Set(true) slider:Set(1) drop:Set("One") multi:Set({ "A" }) input:Set("Other") color:Set(Color3.fromRGB(255,255,255))
check(w:Load(), "actual persistence loads the saved profile")
check(toggle.value == false and slider.value == 70 and drop.value[1] == "Two" and #multi.value == 2 and input.value == "Creator", "all control kinds round-trip their saved values")
check(color:GetValue() == "#112233", "color round-trips through actual persistence")
w.configuration.autoSave = true
local row = tab:CreateGroup()
local col = row:CreateGroup({ direction = "column" })
check(col:CreateToggle({ name = "Nested", value = true }).__type == "Toggle", "native nested groups remain available")
local old = w
local nextWindow = UI:CreateWindow({ Id = "BundleTest", name = "Replacement", configuration = { autoSave = false, autoLoad = false } })
check(old.unloaded and #old.connections == 0, "reexecution tears down the previous window")
check(not nextWindow.configuration.autoSave and not nextWindow.configuration.autoLoad, "explicit persistence opt-outs are respected")
nextWindow:Unload()
check(next(UI.Windows) == nil, "unload releases the window registry")

local DemoUI, demoWindow = (function()
-- DEMO
return UI, window
end)()
check(demoWindow and #demoWindow.tabs >= 5 and demoWindow.layout.mode == "sidebar", "standalone demo builds the native controls")
DemoUI:Destroy()
check(demoWindow.unloaded, "standalone demo tears down cleanly")
print("PASS: " .. checks .. " public-bundle / integration assertions (Roblox services simulated)")
