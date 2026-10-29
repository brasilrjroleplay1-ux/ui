-- Runs against the actual generated bundle inside the upstream Roblox-service shim.
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local UI = (function()
-- BUNDLE
end)()
check(UI.Version == "3.3.2", "new entry point is bundled")
local instanceNew = Instance.new
local openingNodes = {}
Instance.new = function(className)
    local node = instanceNew(className)
    if className == "ScreenGui" or className == "TextLabel" or className == "ImageLabel" then table.insert(openingNodes, node) end
    return node
end
local w = UI:CreateWindow({ Id = "BundleTest", name = "Conexão", theme = "amethyst" })
Instance.new = instanceNew
local openingBrand, openingGui, rayfieldBanner
for _, node in ipairs(openingNodes) do
    if node.Name == "ConexaoStudioStartup" then openingGui = node end
    if node.Text == "Conexão Studio" then openingBrand = node end
    if node:IsA("ImageLabel") and node.Name == "Banner" then rayfieldBanner = node end
end
check(openingBrand and openingGui and not rayfieldBanner, "startup shows Conexão Studio instead of the upstream image banner")
check(openingGui.Parent == nil, "the branded startup GUI is torn down after opening")
check(w.layout.mode == "sidebar", "profile layout is automatic")
check(w.configuration.autoSave and w.configuration.autoLoad, "configuration works without additional setup")
check(w.profileText == "Roblox Studio", "profile subtitle comes from the runtime")
check(w.settings.usageAnalytics == false, "the fork starts with analytics disabled")
check(w.SettingsTab == w.rfSettings, "settings are provided by the actual Gen2 implementation")
check(not w.SettingsTab.neglectSelector and w.SettingsTab.topbarItem and w.selectedTab == w.SettingsTab, "settings are visible in the sidebar and open by default without demo tabs")
check(w.TransparencySlider and w.WindowSizeSlider and w.AutoSizeToggle, "transparency, window size and automatic sizing controls are built into settings")
local initiallySelected = w.selectedTab
w:CloseProfile()
check(w.selectedTab == initiallySelected and not w.ProfilePage, "closing the profile before it was opened leaves navigation unchanged")
check(w.SizeStatus and w.SizeInfo.automatic, "settings and automatic sizing are included with CreateWindow alone")
check(w.WindowSizeSlider.value == w.SizeInfo.percent and w.AutoSizeToggle.value, "the initial slider readout reflects automatic sizing without switching to manual mode")
local scrollFrame, scrollLayout = w.SettingsTab.tabPage, w.SettingsTab.tabPageLayout
local originalScrollView = scrollFrame.AbsoluteWindowSize
local originalContentSize = scrollLayout.AbsoluteContentSize
scrollFrame.AbsoluteWindowSize = Vector2.new(420, 300)
scrollLayout.AbsoluteContentSize = Vector2.new(420, 1800)
scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
check(scrollFrame.AutomaticCanvasSize == Enum.AutomaticSize.None and scrollFrame.CanvasSize.Y.Offset == 1843 and scrollFrame.ScrollBarImageTransparency < 1, "page scroll height includes layout content plus top/bottom padding and shows a scrollbar")
scrollFrame.CanvasPosition = Vector2.new(0, 1543)
scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Fire()
scrollFrame.AbsoluteWindowSize = Vector2.new(420, 600)
scrollFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Fire()
check(scrollFrame.CanvasPosition.Y == 1243, "a page scrolled to the bottom stays at the valid bottom after resizing")
scrollLayout.AbsoluteContentSize = Vector2.new(420, 100)
scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
check(scrollFrame.CanvasPosition.Y == 0 and scrollFrame.ScrollBarImageTransparency == 1, "scroll offset resets when the resized content fits instead of leaving empty scroll space")
scrollFrame.AbsoluteWindowSize, scrollLayout.AbsoluteContentSize = originalScrollView, originalContentSize
scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
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
local portraitPercent = w.WindowSizeSlider.value
check(portraitPercent == w.SizeInfo.percent and portraitPercent ~= 75 and w.UIPreferences.autoSize ~= false, "phone auto fit updates the slider silently instead of leaving a stale manual default")
check(w.main.Size == w.size and w.SizeInfo.screenWidth == 390 and w.SizeStatus.text:find("Automático", 1, true), "a viewport change resizes the window and refreshes the built-in settings status")
resize(Vector2.new(844, 390))
check(w.size.X.Offset <= 820 and w.size.Y.Offset <= 343, "phone rotation fits the new landscape viewport")
check(w.WindowSizeSlider.value == w.SizeInfo.percent and w.WindowSizeSlider.value ~= portraitPercent and w.AutoSizeToggle.value, "rotation recalculates the displayed percentage and keeps automatic mode enabled")
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
local windowChildren = #w.screenGui:GetChildren()
w.ProfileButton.MouseButton1Click:Fire()
local profile = w.ProfilePage
check(profile and profile.playerName.Text == game:GetService("Players").LocalPlayer.DisplayName, "clicking the sidebar opens the actual player's profile")
check(profile.details[2][2] == "Roblox Studio" and profile.avatar.Image ~= "", "profile includes runtime identification and the player's thumbnail")
check(#profile.fields == 2 and w.profileAvatar.Size.X.Offset == 40 and w.ProfileCard.BackgroundTransparency < 1 and w.ProfileButton.ZIndex > w.profileName.ZIndex, "the player card is styled, clickable above its labels and shows only account and executor details")
check(w.selectedTab == w.ProfileTab and profile.content.Parent == w.elements, "the profile opens in the main content panel as a native page")
check(not w._conexaoPanel and not w.screenGui:FindFirstChild("ConexaoOverlay") and #w.screenGui:GetChildren() == windowChildren, "opening the profile creates no floating window or screen-darkening layer")
local dashboard = profile.dashboard
for _, width in ipairs({ 240, 320, 426, 640, 900 }) do
    dashboard.main.AbsoluteSize = Vector2.new(width, 600)
    dashboard:Layout()
    local previousRight, previousBottom = 0, 0
    for index, field in ipairs(profile.fields) do
        local at, size = field.main.Position, field.main.Size
        local left = at.X.Scale * width + at.X.Offset
        local top = at.Y.Offset
        local right = left + size.X.Scale * width + size.X.Offset
        local bottom = top + size.Y.Offset
        assert(left >= 0 and right <= width and bottom <= dashboard.cards.Size.Y.Offset, "profile cards must fit the available content area")
        if index > 1 then assert(left >= previousRight or top >= previousBottom, "profile cards must not overlap") end
        previousRight, previousBottom = right, bottom
    end
    assert(dashboard.actions.Position.Y.Offset >= dashboard.cards.Position.Y.Offset + dashboard.cards.Size.Y.Offset, "actions must remain below the account cards")
    assert(dashboard.main.Size.Y.Offset >= dashboard.actions.Position.Y.Offset + dashboard.actions.Size.Y.Offset, "profile content must remain scrollable through its last action")
end
check(true, "profile cards and actions fit phone, tablet and desktop content widths without overlapping")
dashboard.main.AbsoluteSize = Vector2.new(420, 120)
dashboard:Layout()
local oldClipboard = _G.setclipboard
local copiedId
_G.setclipboard = function(value) copiedId = value end
profile.copyButton.MouseButton1Click:Fire()
check(copiedId == tostring(game:GetService("Players").LocalPlayer.UserId) and dashboard.notice.Visible and not w._conexaoPanel, "copy ID uses the runtime clipboard and reports success inside the profile")
_G.setclipboard = function() return false end
profile.copyButton.MouseButton1Click:Fire()
check(dashboard.notice.Text:find("não está disponível", 1, true) and w.selectedTab == w.ProfileTab, "an unavailable clipboard reports inline and keeps profile navigation working")
_G.setclipboard = oldClipboard
profile.settingsButton.MouseButton1Click:Fire()
check(w.selectedTab == w.SettingsTab, "the profile settings action opens the built-in configuration page")
w:OpenProfile()
profile.themesButton.MouseButton1Click:Fire()
local profileThemes = w._conexaoPanel
check(profileThemes and #profileThemes.cards == 12 and profileThemes.root.Parent == w.elements, "the profile theme action opens theme previews inside the same panel")
profileThemes:Close()
check(w.selectedTab == w.ProfileTab, "returning from theme selection restores the redesigned profile")
w:CloseProfile()
tab:Select()
w:OpenProfile()
profile.backButton.interact.MouseButton1Click:Fire()
check(w.selectedTab == tab, "the profile back button restores the previous tab")
local profileConnections, profileInstances, profileTabs = #w.connections, #w.instances, #w.tabs
for i = 1, 6 do w:OpenProfile() w:CloseProfile() end
check(w.ProfilePage == profile and #w.connections == profileConnections and #w.instances == profileInstances and #w.tabs == profileTabs, "repeated profile navigation reuses one page without accumulating resources")
local removedPrevious = w:CreateTab({ name = "Previous" })
removedPrevious:Select()
w:OpenProfile()
removedPrevious:Remove()
w:CloseProfile()
check(w.selectedTab == tab, "back navigation falls back safely when the previous tab was removed")
w.ProfileTab:Remove()
check(w.ProfilePage == nil and w.ProfileTab == nil, "removing the internal profile page releases its cached references")
profile = w:OpenProfile()
check(w.selectedTab == w.ProfileTab and profile.content.Parent == w.elements, "a removed profile page is rebuilt inside the panel on the next click")
w:CloseProfile()
multi:Open()
local panel = multi.selectionPanel
check(panel and panel.search and #panel.items == 3 and #panel.actions == 3, "multi dropdown opens a separate searchable panel with bulk actions")
check(panel.root.Parent == w.elements and w.selectedTab == panel.tab and not panel.scrim, "dropdown renders as a native content page without a fullscreen popup")
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
panel.closeButton.MouseButton1Click:Fire()
check(not multi._isOpen and not multi.selectionPanel and not w._conexaoPanel, "Back closes the picker and returns to the previous page")
check(w.selectedTab == tab, "closing a dropdown restores the page containing its control")
multi:Open()
local navPanel = multi.selectionPanel
w.SettingsTab.topbarItemInteract.MouseButton1Click:Fire()
check(navPanel.closed and not multi._isOpen and w.selectedTab == w.SettingsTab, "the visible settings entry remains usable while a dropdown is open")
tab:Select()
multi:Open()
local searchPanel = multi.selectionPanel
w.searchAction.interact.MouseButton1Click:Fire()
check(searchPanel.closed and w._searching and w.selectedTab == tab, "global search closes the content picker before entering search mode")
w:OpenSettings()
tab:Select()
multi:Open()
local smallPanel = multi.selectionPanel
local oldSize, oldPosition, oldElementsSize = w.main.AbsoluteSize, w.main.AbsolutePosition, w.elements.AbsoluteSize
w.main.AbsoluteSize, w.main.AbsolutePosition = Vector2.new(320, 480), Vector2.new(0, 0)
w.elements.AbsoluteSize = Vector2.new(256, 416)
smallPanel:Layout()
check(smallPanel.grid.CellSize.X.Scale == 1 and smallPanel.main.Size.X.Scale == 1 and smallPanel.root.Parent == w.elements, "a narrow phone viewport gets one column and a panel inside its safe margins")
w.main.AbsoluteSize, w.main.AbsolutePosition, w.elements.AbsoluteSize = oldSize, oldPosition, oldElementsSize
multi:Close()
multi.main.AbsoluteSize = Vector2.new(240, 70)
multi.main:GetPropertyChangedSignal("AbsoluteSize"):Fire()
check(multi.main.Size.Y.Offset == 70 and multi.selectedLabel.Position.Y.Offset == 38, "a narrow dropdown stacks its title above the chosen value")
multi.main.AbsoluteSize = Vector2.new(420, 41)
multi.main:GetPropertyChangedSignal("AbsoluteSize"):Fire()
drop:Open()
drop.selectionPanel.items[2].hit.MouseButton1Click:Fire()
check(drop:GetValue() == "Two" and not drop._isOpen, "single selection commits the value and closes the panel")
local connections, instances = #w.connections, #w.instances
for i = 1, 6 do multi:Open() multi:Close() end
check(#w.connections == connections and #w.instances == instances, "repeated dropdown use does not accumulate connections or instances")
multi:Open()
w:OpenProfile()
check(not multi._isOpen and not w._conexaoPanel and w.selectedTab == w.ProfileTab, "opening the in-panel profile dismisses an existing dropdown overlay")
w:CloseProfile()

check(w.SettingsTab.name == "Configurações" and w.AutoSaveToggle and w.AutoLoadToggle and w.ThemeGallery, "settings and theme previews are included without script-side setup")
check(#w.ThemeGallery.cards == 6 and #UI.Themes == 12, "six vivid presets and six original themes have palettes and previews")
w.ThemeGallery.cards[5].hit.MouseButton1Click:Fire()
check(w.ThemeId == "sakura" and w.ThemeGallery.cards[5].selected.Visible, "a preview applies its real theme and marks the selection")
check(w.ProfilePage.fields[1].valueLabel.TextColor3 == w.theme.ContentColor, "the in-panel profile follows live theme changes")
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
bw.TransparencySlider:Set(37)
check(math.abs(bw.windowGradient.Transparency.Keypoints[1].Value - 0.37) < 0.001 and bw.theme.ElementTransparency == 0.37, "the transparency setting changes window and control backgrounds immediately")
bw:Hide() bw:Show()
check(math.abs(bw.windowGradient.Transparency.Keypoints[1].Value - 0.37) < 0.001 and bw.bottomFadeGradient.Transparency.Keypoints[1].Value >= 0.37, "reopening retains the selected transparency and the fade also remains transparent")
bw:ChangeTheme("aurora")
check(bw.ThemeId == "aurora" and math.abs(bw.windowGradient.Transparency.Keypoints[1].Value - 0.37) < 0.001, "theme changes retain transparency and the theme identity")
bw:OpenSettings()
local sizeSlider = bw.WindowSizeSlider
local beforeGestureSize, beforeGesturePercent = bw.main.Size, bw.UIPreferences.sizePercent
local previousMouse = game:GetService("UserInputService"):GetMouseLocation()
local refreshSize = bw.RefreshSize
local appliedSizes = 0
bw.RefreshSize = function(self, ...) appliedSizes += 1 return refreshSize(self, ...) end
game:GetService("UserInputService")._setMouseLocation(Vector2.new(sizeSlider.track.AbsolutePosition.X + 20, 0))
sizeSlider.interact.InputBegan:Fire({ UserInputType = Enum.UserInputType.MouseButton1 })
check(sizeSlider.dragging and bw.main.Size == beforeGestureSize and bw.UIPreferences.sizePercent == beforeGesturePercent and appliedSizes == 0, "holding the size handle previews a value without resizing or committing preferences")
check(not bw.SettingsTab.tabPage.ScrollingEnabled and bw.SizeStatus.text:find("solte", 1, true), "page scroll is held during the gesture and the pending size is clearly labeled")
game:GetService("UserInputService")._setMouseLocation(Vector2.new(sizeSlider.track.AbsolutePosition.X + 300, 0))
game:GetService("RunService").RenderStepped:Fire()
game:GetService("RunService").Heartbeat:Fire(2.1)
check(bw.main.Size == beforeGestureSize and appliedSizes == 0, "drag updates and the viewport backstop cannot move the slider's window while held")
local releasedSizeValue = sizeSlider.value
game:GetService("UserInputService").InputEnded:Fire({ UserInputType = Enum.UserInputType.MouseButton1 })
check(not sizeSlider.dragging and bw.UIPreferences.sizePercent == releasedSizeValue and appliedSizes == 1 and bw.SettingsTab.tabPage.ScrollingEnabled, "release commits the final size once and restores page scrolling")
game:GetService("UserInputService")._setMouseLocation(Vector2.new(sizeSlider.track.AbsolutePosition.X + 20, 0))
sizeSlider.interact.InputBegan:Fire({ UserInputType = Enum.UserInputType.Touch })
game:GetService("UserInputService").WindowFocusReleased:Fire()
check(not sizeSlider.dragging and appliedSizes == 2 and bw.SettingsTab.tabPage.ScrollingEnabled and not bw._sizePreview, "focus loss finishes a size gesture and releases the scroll hold")
bw.RefreshSize = refreshSize
game:GetService("UserInputService")._setMouseLocation(previousMouse)
bw.WindowSizeSlider:Set(100)
check(not bw.AutoSizeToggle.value and not bw.SizeInfo.automatic and bw.size.X.Offset >= bw.SizeInfo.screenWidth * 0.9 and bw.size.X.Offset <= bw.SizeInfo.screenWidth, "dragging size enables manual mode and 100 percent fills the available screen")
bMulti:Open()
bMulti.selectionPanel.actions[1].MouseButton1Click:Fire()
check(#bMulti.value == 0, "default on a late-restored dropdown uses the script's empty default, not its saved selection")
bMulti:Close()
bw.AutoSaveToggle:Set(false)
bw.AutoLoadToggle:Set(false)
bw:Unload()
local cw = UI:CreateWindow({ Id = "AutoPersist31", name = "AutoPersist31" })
check(not cw.configuration.autoSave and not cw.configuration.autoLoad, "automatic settings remember the user's persistence preferences")
check(cw.TransparencySlider.value == 37 and cw.WindowSizeSlider.value == 100 and not cw.AutoSizeToggle.value and cw.ThemeId == "aurora", "appearance, size mode and theme selections survive reexecution")
cw.WindowSizeSlider:Set(0)
check(cw.size.X.Offset > 0 and cw.size.Y.Offset > 0 and cw.size.X.Offset <= cw.SizeInfo.screenWidth, "zero percent keeps a usable compact window rather than hiding settings")
cw.AutoSizeToggle:Set(true)
check(cw.SizeInfo.automatic and cw.SizeStatus.text:find("Automático", 1, true), "the automatic sizing toggle restores automatic fitting")
check(cw.WindowSizeSlider.value == cw.SizeInfo.percent and cw.WindowSizeSlider.value ~= 0 and cw.UIPreferences.sizePercent == 0, "automatic mode updates the readout while preserving the last saved manual choice")
cw.AutoSizeToggle:Set(false)
check(cw.WindowSizeSlider.value == 0 and not cw.SizeInfo.automatic, "returning to manual mode restores its corresponding slider value")
cw.WindowSizeSlider:Set(49)
cw.AutoSizeToggle:Set(true)
cw:Unload()
local dw = UI:CreateWindow({ Id = "AutoPersist31", name = "AutoPersist31" })
check(dw.AutoSizeToggle.value and dw.UIPreferences.sizePercent == 49 and dw.WindowSizeSlider.value == dw.SizeInfo.percent and dw.WindowSizeSlider.value ~= 49, "reexecution with automatic mode ignores a stale saved manual percentage for the displayed slider")
dw:Unload()

local removed = w:CreateTab({ name = "Temporary" })
local transient = removed:CreateDropdown({ name = "Temporary", options = { "X" } })
transient:Open()
removed:Remove()
check(not w._conexaoPanel and not transient._isOpen, "removing an open dropdown's tab also tears down its overlay")
w:OpenProfile()
w:Hide()
check(not w._conexaoPanel and w.selectedTab == w.ProfileTab, "hiding preserves the profile as a normal internal page")
w:Show()
check(w.selectedTab == w.ProfileTab and w.ProfilePage.content.Parent == w.elements, "reopening keeps the profile inside the main panel")
w:CloseProfile()

local previousIdentify = _G.identifyexecutor
_G.identifyexecutor = function() return "Test Executor", "1.2.3" end
local ew = UI:CreateWindow({ Id = "ExecutorTest", name = "ExecutorTest", sidebarLayout = false })
check(not ew.ProfileButton and ew.ExecutorInfo.name == "Test Executor" and ew.ExecutorInfo.version == "1.2.3", "executor identity and version are detected while the top-tab layout stays supported")
ew:OpenProfile()
check(ew.selectedTab == ew.ProfileTab and ew.ProfilePage.content.Parent == ew.elements and not ew._conexaoPanel, "the top-tab layout also presents the profile inside its content panel")
ew:Unload()
check(not ew.ProfilePage and not ew.ProfileTab and #ew.connections == 0, "unloading with a profile open releases its page references and handlers")
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
check(demoWindow and #demoWindow.tabs == 1 and demoWindow.selectedTab == demoWindow.SettingsTab, "the clean standalone demo opens only the built-in settings page")
DemoUI:Destroy()
check(demoWindow.unloaded, "standalone demo tears down cleanly")

local ComponentsUI, componentsWindow = (function()
-- COMPONENTS
return UI, window
end)()
check(componentsWindow and #componentsWindow.tabs >= 5 and componentsWindow.selectedTab.name == "Início", "the separate component example retains all API demonstrations")
ComponentsUI:Destroy()

print("PASS: " .. checks .. " public-bundle / integration assertions (Roblox services simulated)")
