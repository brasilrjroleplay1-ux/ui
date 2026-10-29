-- Runs against the actual generated bundle inside the upstream Roblox-service shim.
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local UI = (function()
-- BUNDLE
end)()
check(UI.Version == "3.1.1", "new entry point is bundled")
local w = UI:CreateWindow({ Id = "BundleTest", name = "Conexão", theme = "amethyst" })
check(w.layout.mode == "sidebar", "profile layout is automatic")
check(w.configuration.autoSave and w.configuration.autoLoad, "configuration works without additional setup")
check(w.profileText == "Roblox Studio", "profile subtitle comes from the runtime")
check(w.settings.usageAnalytics == false, "the fork starts with analytics disabled")
check(w.SettingsTab == w.rfSettings, "settings are provided by the actual Gen2 implementation")
check(w.SizeStatus and w.SizeInfo.automatic, "settings and automatic sizing are included with CreateWindow alone")
local originalCamera = workspace.CurrentCamera
local camera = Instance.new("Camera")
camera.ViewportSize = Vector2.new(1024, 768)
workspace.CurrentCamera = camera
workspace:GetPropertyChangedSignal("CurrentCamera"):Fire()
local originalGuiSize = w.screenGui.AbsoluteSize
local function resize(viewport)
    w.screenGui.AbsoluteSize = viewport
    camera.ViewportSize = viewport
    -- Property events must be fired explicitly by this table-based Roblox shim.
    camera:GetPropertyChangedSignal("ViewportSize"):Fire()
end
resize(Vector2.new(390, 844))
check(w.size.X.Offset <= 366 and w.size.Y.Offset >= 500 and w.size.Y.Offset <= 772, "portrait phone uses its height while fitting within the screen")
check(w.main.Size == w.size and w.SizeStatus.text:find("390 × 844", 1, true), "a viewport change resizes the window and refreshes the built-in settings status")
resize(Vector2.new(844, 390))
check(w.size.X.Offset <= 820 and w.size.Y.Offset <= 343, "phone rotation fits the new landscape viewport")
w:Hide()
local collapsedSize = w.main.Size
resize(Vector2.new(390, 844))
check(w.hidden and w.main.Size == collapsedSize, "rotation does not reopen a hidden window")
w:Show()
check(w.main.Size == w.size and w.size.Y.Offset >= 500, "reopening uses the most recent screen dimensions")
local replacementCamera = Instance.new("Camera")
replacementCamera.ViewportSize = Vector2.new(1024, 768)
workspace.CurrentCamera = replacementCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Fire()
replacementCamera.ViewportSize = Vector2.new(360, 800)
replacementCamera:GetPropertyChangedSignal("ViewportSize"):Fire()
check(w.SizeInfo.screenWidth == 360 and w.size.X.Offset <= 336, "camera replacement keeps automatic resizing connected")
replacementCamera.ViewportSize = Vector2.new(1, 1)
w.screenGui.AbsoluteSize = Vector2.new(360, 800)
w.screenGui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
check(w.SizeInfo.screenWidth == 360, "an initializing camera falls back to the actual GUI viewport")
replacementCamera.ViewportSize = Vector2.new(240, 180)
replacementCamera:GetPropertyChangedSignal("ViewportSize"):Fire()
check(w.size.X.Offset <= 240 and w.size.Y.Offset <= 180, "even a small split-screen remains inside its viewport")
workspace.CurrentCamera = originalCamera
w.screenGui.AbsoluteSize = originalGuiSize
workspace:GetPropertyChangedSignal("CurrentCamera"):Fire()
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

-- Exercise the actual hit targets, not only the native Set API.
local baselineConnections, baselineInstances = #w.connections, #w.instances
w.ProfileButton.MouseButton1Click:Fire()
local profile = w._conexaoModal
check(profile and profile.playerName.Text == game:GetService("Players").LocalPlayer.DisplayName, "clicking the sidebar opens the actual player's profile")
check(profile.details[2][2] == "Roblox Studio" and profile.avatar.Image ~= "", "profile includes runtime identification and the player's thumbnail")
profile.closeButton.MouseButton1Click:Fire()
check(not w._conexaoModal and #w.connections == baselineConnections and #w.instances == baselineInstances, "closing a profile releases its instances and input handlers")
multi:Open()
local panel = multi.selectionPanel
check(panel and panel.search and #panel.items == 3 and #panel.actions == 3, "multi dropdown opens a separate searchable panel with bulk actions")
panel.shield.MouseButton1Click:Fire()
check(not panel.closed, "blank panel space absorbs clicks without dismissing the overlay")
check(multi.main.Size.Y.Offset == 41 and multi.panel.Visible == false, "dropdown does not expand or push the underlying page")
panel.search.Text = "b"
-- The upstream table shim does not emit property events on existing raw keys.
panel.search:GetPropertyChangedSignal("Text"):Fire()
check(not panel.items[1].frame.Visible and panel.items[2].frame.Visible and not panel.items[3].frame.Visible, "panel search filters option cards")
panel.actions[3].MouseButton1Click:Fire()
check(#multi.value == 3, "select all includes all options even with an active filter")
panel.actions[2].MouseButton1Click:Fire()
check(#multi.value == 0, "clear removes every selected value")
panel.actions[1].MouseButton1Click:Fire()
check(#multi.value == 1 and multi.value[1] == "A", "default restores the script's original choices")
panel.items[2].hit.MouseButton1Click:Fire()
check(#multi.value == 2 and table.find(multi.value, "B") ~= nil, "a multi-select card toggles independently without closing the panel")
multi:Refresh({ "A", "B", "C", "D" })
check(#panel.items == 4 and multi.main.Size.Y.Offset == 41, "Refresh rebuilds the open panel while preserving the compact header")
panel.scrim.MouseButton1Click:Fire()
check(not multi._isOpen and not multi.selectionPanel and not w._conexaoModal, "clicking outside closes the panel")
multi:Open()
local smallPanel = multi.selectionPanel
local oldSize, oldPosition = w.main.AbsoluteSize, w.main.AbsolutePosition
w.main.AbsoluteSize, w.main.AbsolutePosition = Vector2.new(320, 480), Vector2.new(0, 0)
smallPanel.root.AbsoluteSize = Vector2.new(320, 568)
smallPanel:Layout()
check(smallPanel.grid.CellSize.X.Scale == 1 and smallPanel.panel.Size.X.Offset <= 296, "a narrow phone viewport gets one column and a panel inside its safe margins")
w.main.AbsoluteSize, w.main.AbsolutePosition = oldSize, oldPosition
multi:Close()
drop:Open()
drop.selectionPanel.items[2].hit.MouseButton1Click:Fire()
check(drop:GetValue() == "Two" and not drop._isOpen, "single selection commits the value and closes the panel")
local connections, instances = #w.connections, #w.instances
for i = 1, 6 do multi:Open() multi:Close() end
check(#w.connections == connections and #w.instances == instances, "repeated dropdown use does not accumulate connections or instances")
multi:Open()
w:OpenProfile()
check(not multi._isOpen and w._conexaoModal.playerName ~= nil, "only one overlay is open at a time")
w._conexaoModal:Close()

check(w.SettingsTab.name == "Configurações" and w.AutoSaveToggle and w.AutoLoadToggle and w.ThemeGallery, "settings and theme previews are included without script-side setup")
check(#w.ThemeGallery.cards == 6 and #UI.Themes == 12, "six vivid presets and six original themes have palettes and previews")
w.ThemeGallery.cards[5].hit.MouseButton1Click:Fire()
check(w.ThemeId == "sakura" and w.ThemeGallery.cards[5].selected.Visible, "a preview applies its real theme and marks the selection")
local themes = w:OpenThemes()
check(#themes.cards == 12, "the complete theme picker renders all twelve previews")
themes.cards[2].hit.MouseButton1Click:Fire()
check(w.ThemeId == "aurora" and themes.cards[2].selected.Visible and w.theme.AccentColor == UI.Themes[2].theme.AccentColor, "theme preview colors match the applied palette")
w:OpenSettings()
check(w.selectedTab == w.SettingsTab and themes.closed, "opening settings closes the overlay")

-- Native autosave and late restoration, through the integration's default configuration.
-- There is deliberately no explicit Save/Load in this scenario.
local aw = UI:CreateWindow({ Id = "AutoPersist31", name = "AutoPersist31" })
local at = aw:CreateTab({ name = "Values" })
local aToggle = at:CreateToggle({ name = "Toggle", flag = "auto/toggle", value = false })
local aSlider = at:CreateSlider({ name = "Slider", flag = "auto/slider", range = { 0, 100 }, value = 1 })
local aSingle = at:CreateDropdown({ name = "Single", flag = "auto/single", options = { "A", "B" }, value = "A" })
local aMulti = at:CreateDropdown({ name = "Multi", flag = "auto/multi", options = { "A", "B", "C" }, multiSelect = true })
local aInput = at:CreateInput({ name = "Input", flag = "auto/input", value = "Before" })
local aKey = at:CreateKeybind({ name = "Key", flag = "auto/key", value = Enum.KeyCode.F6 })
local aColor = at:CreateColorPicker({ name = "Color", flag = "auto/color", color = Color3.fromRGB(1, 2, 3) })
aToggle:Set(true) aSlider:Set(84) aSingle:Set("B") aMulti:Set({ "B", "C" }) aInput:Set("Restored") aKey:Set(Enum.KeyCode.F7) aColor:Set(Color3.fromRGB(44, 55, 66))
check(aw.SaveStatus.success == true and aw.SaveStatus.persistent == false, "autosave reports successful session storage truthfully in Studio")
aw:ChangeTheme("onyx")
aw:Unload()
local bw = UI:CreateWindow({ Id = "AutoPersist31", name = "AutoPersist31" })
local bt = bw:CreateTab({ name = "Values" })
local restoredCallback
local bToggle = bt:CreateToggle({ name = "Toggle", flag = "auto/toggle", value = false, callback = function(value) restoredCallback = value end })
local bSlider = bt:CreateSlider({ name = "Slider", flag = "auto/slider", range = { 0, 100 }, value = 1 })
local bSingle = bt:CreateDropdown({ name = "Single", flag = "auto/single", options = { "A", "B" }, value = "A" })
local bMulti = bt:CreateDropdown({ name = "Multi", flag = "auto/multi", options = { "A", "B", "C" }, multiSelect = true })
local bInput = bt:CreateInput({ name = "Input", flag = "auto/input", value = "Before" })
local bKey = bt:CreateKeybind({ name = "Key", flag = "auto/key", value = Enum.KeyCode.F6 })
local bColor = bt:CreateColorPicker({ name = "Color", flag = "auto/color", color = Color3.fromRGB(1, 2, 3) })
check(bToggle.value and restoredCallback == true and bSlider.value == 84, "reexecution restores toggle and slider and invokes the restored callback")
check(bSingle:GetValue() == "B" and #bMulti.value == 2 and bInput.value == "Restored", "reexecution restores unique/multiple dropdowns and text")
check(bKey.value == Enum.KeyCode.F7 and bColor:GetValue():upper() == "#2C3742", "reexecution restores keybind and color")
check(bw.ThemeId == "onyx", "theme selection survives reexecution independently of control flags")
bMulti:Open()
bMulti.selectionPanel.actions[1].MouseButton1Click:Fire()
check(#bMulti.value == 0, "default on a late-restored dropdown uses the script's empty default, not its saved selection")
bMulti:Close()
bw.AutoSaveToggle:Set(false)
bw.AutoLoadToggle:Set(false)
bw:Unload()
local cw = UI:CreateWindow({ Id = "AutoPersist31", name = "AutoPersist31" })
check(not cw.configuration.autoSave and not cw.configuration.autoLoad, "automatic settings remember the user's persistence preferences")
cw:Unload()

local removed = w:CreateTab({ name = "Temporary" })
local transient = removed:CreateDropdown({ name = "Temporary", options = { "X" } })
transient:Open()
removed:Remove()
check(not w._conexaoModal and not transient._isOpen, "removing an open dropdown's tab also tears down its overlay")
w:OpenProfile()
w:Hide()
check(not w._conexaoModal, "hiding the window closes transient panels")
w:Show()

local previousIdentify = _G.identifyexecutor
_G.identifyexecutor = function() return "Test Executor", "1.2.3" end
local ew = UI:CreateWindow({ Id = "ExecutorTest", name = "ExecutorTest", sidebarLayout = false })
check(not ew.ProfileButton and ew.ExecutorInfo.name == "Test Executor" and ew.ExecutorInfo.version == "1.2.3", "executor identity and version are detected while the top-tab layout stays supported")
ew:OpenProfile()
ew:Unload()
check(not ew._conexaoModal and #ew.connections == 0, "unloading with a profile open releases all overlay resources")
_G.identifyexecutor = previousIdentify

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
