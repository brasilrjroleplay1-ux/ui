-- Runs against the actual generated bundle inside the upstream Roblox-service shim.
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local function childOfClass(parent, class)
    for _, child in ipairs(parent:GetChildren()) do if child:IsA(class) then return child end end
end
local UI = (function()
-- BUNDLE
end)()
check(UI.Version == "3.14.0", "new entry point is bundled")
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
local nativeControls = {}
for _, element in ipairs(w.SettingsTab.elements) do
    if element.name then nativeControls[element.name] = element end
end
for source, translated in pairs({
    ["Toggle Keybind"] = "Tecla para abrir / fechar",
    ["Unlock cursor while open"] = "Liberar cursor com o menu aberto",
    ["Welcome toast"] = "Aviso de boas-vindas",
    ["Haptics"] = "Vibração ao tocar",
    ["Show profile"] = "Mostrar meu perfil na lateral",
    ["Keep window on screen"] = "Manter a janela dentro da tela",
}) do
    check(nativeControls[source] and nativeControls[source].title.Text == translated, "native setting is translated: " .. source)
end
check(not nativeControls["Usage analytics"], "disabled analytics cannot be re-enabled by a settings toggle")
check(nativeControls["Haptics"].descriptor.titleLabel.Text:find("Vibração leve", 1, true), "settings descriptions are translated through the native locale bindings")
local haptics = nativeControls["Haptics"]
local previousHaptics = haptics.value
haptics:Set(not previousHaptics)
check(w.settings.haptics == not previousHaptics, "translated controls still call their original setting callbacks")
haptics:Set(previousHaptics)
check(w.SettingsTab == w.rfSettings, "settings are provided by the actual Gen2 implementation")
check(not w.SettingsTab.neglectSelector and w.SettingsTab.topbarItem and w.selectedTab == w.SettingsTab, "settings are visible in the sidebar and open by default without demo tabs")
check(w.TransparencySlider and w.WindowSizeSlider and w.AutoSizeToggle, "transparency, window size and automatic sizing controls are built into settings")
local initiallySelected = w.selectedTab
w:CloseProfile()
check(w.selectedTab == initiallySelected and not w.HomePage, "closing the profile before it was opened leaves navigation unchanged")
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
w:OpenHome()
w.HomeTab.topbarItemInteract.MouseButton1Click:Fire()
local profile = w.HomePage
check(profile and profile.playerName.Text == "Olá, " .. game:GetService("Players").LocalPlayer.DisplayName, "Home opens the actual player's greeting")
check(profile.details[2][2] == "Roblox Studio" and profile.avatar.Image ~= "", "profile includes runtime identification and the player's thumbnail")
check(profile.avatar.Image:find("w=420&h=420", 1, true) and w.profileAvatar.Image:find("w=420&h=420", 1, true), "both profile and sidebar use a 420px thumbnail instead of upscaling the old 48px headshot")
check(profile.avatar.ScaleType == Enum.ScaleType.Fit and profile.avatar.ResampleMode == Enum.ResamplerMode.Default, "avatar keeps its aspect ratio and smooth resampling")
check(profile.platformIcon.kind == "studio" and #profile.platformIcon.parts == 4 and profile.fields[2].icon.kind == "roblox", "platform and account have local Studio and Roblox marks")
check(#profile.fields == 2 and w.profileAvatar.Size.X.Offset == 36 and w.ProfileCard.BackgroundTransparency < 1 and w.ProfileButton.ZIndex > w.profileName.ZIndex, "the compact avatar card stays clickable above its labels")
check(w.selectedTab == w.HomeTab and profile.content.Parent == w.elements, "the profile opens in the main content panel as a native page")
check(not w._conexaoPanel and not w.screenGui:FindFirstChild("ConexaoOverlay") and #w.screenGui:GetChildren() == windowChildren, "opening the profile creates no floating window or screen-darkening layer")
local dashboard = profile.dashboard
check(not dashboard.banner:FindFirstChild("Shading") and not dashboard.banner:FindFirstChild("Orbit"), "the rounded banner contains no rectangular shade or clipped off-canvas circles")
local function rect(node, parentWidth, parentHeight)
    local size, at, anchor = node.Size, node.Position, node.AnchorPoint
    local width = size.X.Scale * parentWidth + size.X.Offset
    local height = size.Y.Scale * parentHeight + size.Y.Offset
    return at.X.Scale * parentWidth + at.X.Offset - anchor.X * width, at.Y.Scale * parentHeight + at.Y.Offset - anchor.Y * height, width, height
end
local function inside(node, width, height, name)
    local x, y, w, h = rect(node, width, height)
    assert(x >= 0 and y >= 0 and w > 0 and h > 0 and x + w <= width + 0.01 and y + h <= height + 0.01, name .. " must fit without clipping")
end
check(not profile.settingsButton and not profile.themesButton and not profile.copyServerButton and not dashboard.actions, "home omits the settings, theme and copy-server shortcuts requested for removal")
for _, node in ipairs(dashboard.main:GetDescendants()) do
    check(not node:IsA("TextButton") or (node.Text ~= "Configurações" and node.Text ~= "Temas" and node.Text ~= "Copiar servidor"), "no removed shortcut is left hidden in Home")
end
for _, width in ipairs({ 180, 219, 240, 320, 399, 419, 420, 426, 440, 550, 559, 560, 640, 820, 900 }) do
    dashboard.main.AbsoluteSize = Vector2.new(width, 600)
    dashboard:Layout()
    local _, _, bannerWidth, bannerHeight = rect(dashboard.banner, width, dashboard.hero.Size.Y.Offset)
    inside(dashboard.banner, width, dashboard.hero.Size.Y.Offset, "welcome banner")
    assert(bannerHeight == 60, "greeting keeps the reference's compact outlined strip")
    assert(dashboard.cards.Position.Y.Offset >= dashboard.hero.Position.Y.Offset + dashboard.hero.Size.Y.Offset + 12, "cards must remain below the greeting")
    assert(dashboard.main.Size.Y.Offset >= dashboard.cards.Position.Y.Offset + dashboard.cards.Size.Y.Offset, "all session details must remain scrollable")
    inside(dashboard.plate, width, dashboard.hero.Size.Y.Offset, "separate avatar")
    for _, node in ipairs({ profile.playerName, profile.username }) do inside(node, bannerWidth, bannerHeight, node.Name) end
    local bx = rect(dashboard.banner, width, dashboard.hero.Size.Y.Offset)
    assert(bx >= dashboard.plate.Size.X.Offset + 12, "avatar and greeting are separate surfaces with an even gutter")
    inside(profile.avatar, dashboard.plate.Size.X.Offset, dashboard.plate.Size.Y.Offset, "avatar")
    inside(dashboard.session, width, dashboard.cards.Size.Y.Offset, "session panel")
    inside(profile.fields[1].main, width, dashboard.cards.Size.Y.Offset, "client card")
    inside(profile.fields[2].main, width, dashboard.main.Size.Y.Offset, "account footer")
    inside(dashboard.save, width, dashboard.cards.Size.Y.Offset, "save note")
    inside(dashboard.friends, width, dashboard.cards.Size.Y.Offset, "friends panel")
    local sx, sy, sw, sh = rect(dashboard.session, width, dashboard.cards.Size.Y.Offset)
    local cx, cy, cw, ch = rect(profile.fields[1].main, width, dashboard.cards.Size.Y.Offset)
    local ax, ay, aw = rect(profile.fields[2].main, width, dashboard.main.Size.Y.Offset)
    local fx, fy, fw, fh = rect(dashboard.friends, width, dashboard.cards.Size.Y.Offset)
    if width >= 400 then
        assert(cx >= sx + sw + 10 and fx == cx and cy == sy and fy >= cy + ch + 10, "reference composition keeps server/save left and client/friends right")
        assert(dashboard.main.Size.Y.Offset <= 400, "all primary Home cards fit a compact page at screenshot widths")
    else
        assert(cx == 0 and cy >= sy + sh + 80 and fy >= cy + ch + 10, "phone cards stack without hiding client information")
    end
    for _, stat in ipairs(dashboard.friendStats) do
        inside(stat.main, fw, fh, "friend stat")
        inside(stat.value, stat.main.Size.X.Offset, stat.main.Size.Y.Offset, "friend value")
    end
    for _, stat in ipairs(dashboard.stats) do
        inside(stat.main, sw, sh, "session stat")
        inside(stat.caption, stat.main.Size.X.Offset, stat.main.Size.Y.Offset, "stat caption")
        inside(stat.value, stat.main.Size.X.Offset, stat.main.Size.Y.Offset, "stat value")
    end
    for _, field in ipairs(profile.fields) do
        local fieldWidth = field.main.Size.X.Offset
        for _, node in ipairs({ field.heading, field.valueLabel, field.subtitle, field.icon.root }) do if node.Visible ~= false then inside(node, fieldWidth, field.main.Size.Y.Offset, "card content") end end
    end
    inside(dashboard.platformPill, cw, ch, "platform badge")
    inside(dashboard.clientNote, cw, ch, "client status")
    inside(profile.copyButton, aw, profile.fields[2].main.Size.Y.Offset, "copy account ID")
end
check(true, "compact Home cards fit phone, tablet and desktop content widths without overlapping")
dashboard.main.AbsoluteSize = Vector2.new(420, 120)
dashboard:Layout()
local oldClipboard = _G.setclipboard
local copiedId
_G.setclipboard = function(value) copiedId = value end
profile.copyButton.MouseButton1Click:Fire()
check(copiedId == tostring(game:GetService("Players").LocalPlayer.UserId) and dashboard.notice.Visible and not w._conexaoPanel, "copy ID uses the runtime clipboard and reports success inside the profile")
_G.setclipboard = function() return false end
profile.copyButton.MouseButton1Click:Fire()
check(dashboard.notice.Text:find("não está disponível", 1, true) and w.selectedTab == w.HomeTab, "an unavailable clipboard reports inline and keeps profile navigation working")
_G.setclipboard = oldClipboard
w:OpenSettings()
check(w.selectedTab == w.SettingsTab, "built-in settings remain available after removing the duplicate Home shortcut")
w:OpenHome()
w:OpenThemes()
local profileThemes = w._conexaoPanel
check(profileThemes and #profileThemes.cards == 60 and profileThemes.root.Parent == w.elements, "theme previews remain available inside the same panel")
profileThemes:Close()
check(w.selectedTab == w.HomeTab, "returning from theme selection restores the redesigned profile")
w:CloseProfile()
tab:Select()
w:OpenHome()
w:CloseProfile()
check(w.selectedTab == tab, "the profile back button restores the previous tab")
local profileConnections, profileInstances, profileTabs = #w.connections, #w.instances, #w.tabs
for i = 1, 6 do w:OpenHome() w:CloseProfile() end
check(w.HomePage == profile and #w.connections == profileConnections and #w.instances == profileInstances and #w.tabs == profileTabs, "repeated profile navigation reuses one page without accumulating resources")
local removedPrevious = w:CreateTab({ name = "Previous" })
removedPrevious:Select()
w:OpenHome()
removedPrevious:Remove()
w:CloseProfile()
check(w.selectedTab == tab, "back navigation falls back safely when the previous tab was removed")
w.HomeTab:Remove()
check(w.HomePage == nil and w.HomeTab == nil, "removing the internal profile page releases its cached references")
profile = w:OpenHome()
check(w.selectedTab == w.HomeTab and profile.content.Parent == w.elements, "a removed profile page is rebuilt inside the panel on the next click")
w:CloseProfile()
multi:Open()
local panel = multi.selectionPanel
check(panel and panel.search and #panel.items == 3 and #panel.actions == 3, "multi dropdown opens a separate searchable panel with bulk actions")
check(panel.root.Parent == w.main and w.selectedTab == tab and not panel.scrim, "dropdown splits the content inside the main window without changing tabs")
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
check(#multi.value == 2 and table.find(multi.value, "B") ~= nil, "a multi-select checkbox toggles independently without closing the panel")
multi:Refresh({ "A", "B", "C", "D" })
check(#panel.items == 4 and multi.main.Size.Y.Offset == 41, "Refresh rebuilds the open panel while preserving the compact header")
panel.closeButton.MouseButton1Click:Fire()
check(not multi._isOpen and not multi.selectionPanel and not w._conexaoPanel, "Close dismisses only the anchored picker")
check(w.selectedTab == tab, "closing a dropdown keeps its original page selected")
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
check(smallPanel.grid:IsA("UIGridLayout") and smallPanel.columns == 1 and smallPanel.main.Size.X.Offset <= 300 and smallPanel.root.Parent == w.main, "a narrow window keeps the options in an internal one-column pane")
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
w:OpenHome()
check(not multi._isOpen and not w._conexaoPanel and w.selectedTab == w.HomeTab, "opening the in-panel profile dismisses an existing dropdown overlay")
w:CloseProfile()

check(w.SettingsTab.name == "Configurações" and w.AutoSaveToggle and w.AutoLoadToggle and w.ThemeGallery, "settings and theme previews are included without script-side setup")
check(#w.ThemeGallery.cards == 6 and #UI.Themes == 60, "six featured previews and sixty complete palettes are available")
do
local gallery = w.ThemeGallery
local gallerySize, galleryElements = gallery.main.AbsoluteSize, w.elements.AbsoluteSize
local galleryView, galleryContent = gallery.gridFrame.AbsoluteWindowSize, gallery.grid.AbsoluteContentSize
for _, dimensions in ipairs({ { 280, 300 }, { 520, 480 }, { 820, 900 } }) do
    local width, height = dimensions[1], dimensions[2]
    gallery.main.AbsoluteSize = Vector2.new(width, 400)
    w.elements.AbsoluteSize = Vector2.new(width + 40, height)
    gallery:Layout()
    local viewport = gallery.main.Size.Y.Offset - 88
    check(viewport >= 156 and viewport <= 300 and gallery.main.Size.Y.Offset <= 388, "featured previews use a bounded viewport instead of adding six full cards to settings")
    local columns = width < 380 and 1 or (width >= 690 and 3 or 2)
    gallery.gridFrame.AbsoluteWindowSize = Vector2.new(width - 6, viewport)
    gallery.grid.AbsoluteContentSize = Vector2.new(width - 6, math.ceil(6 / columns) * 168 - 12)
    gallery.scroll:Queue()
    check(gallery.gridFrame:IsA("ScrollingFrame") and gallery.gridFrame.ScrollingEnabled and gallery.gridFrame.ClipsDescendants and gallery.gridFrame.CanvasSize.Y.Offset > viewport, "featured themes scroll and clip inside their own fixed area")
    local beforeButton = gallery.more.Position
    gallery.gridFrame.CanvasPosition = Vector2.new(0, gallery.gridFrame.CanvasSize.Y.Offset - viewport)
    gallery.gridFrame:GetPropertyChangedSignal("CanvasPosition"):Fire()
    check(gallery.scroll.atEnd and gallery.more.Position == beforeButton, "featured theme scroll reaches the bottom while the catalogue button stays outside the scroller")
end
gallery.main.AbsoluteSize, w.elements.AbsoluteSize = gallerySize, galleryElements
gallery.gridFrame.AbsoluteWindowSize, gallery.grid.AbsoluteContentSize = galleryView, galleryContent
gallery:Layout()
end
w.ThemeGallery.cards[5].hit.MouseButton1Click:Fire()
check(w.ThemeId == "porcelana" and w.ThemeGallery.cards[5].selected.Visible, "a preview applies its real theme and marks the selection")
check(w.HomePage.fields[1].valueLabel.TextColor3 == w.theme.ContentColor, "the in-panel profile follows live theme changes")
check(w.HomePage.platformIcon.parts[1].BackgroundColor3 == w.theme.ContentColor, "platform marks follow the text color to stay readable on light cards")
do
    local function luminance(color)
        local function channel(v) return v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4 end
        return 0.2126 * channel(color.R) + 0.7152 * channel(color.G) + 0.0722 * channel(color.B)
    end
    local function contrast(a, b)
        local x, y = luminance(a), luminance(b)
        return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05)
    end
    local previous = w.ThemeId
    for _, id in ipairs({ "conexao", "ember", "rose", "porcelana", "matcha", "frost" }) do
        w:ChangeTheme(id)
        local home = w.HomePage.dashboard
        for _, node in ipairs({ home.session, home.save, home.friends, w.HomePage.fields[1].main }) do
            local gradient = childOfClass(node, "UIGradient")
            for _, point in ipairs(gradient.Color.Keypoints) do
                check(contrast(w.theme.ContentColor, point.Value) >= 4.5, "Home text contrasts with each surface in " .. id)
            end
        end
        home:_setShown(true, false)
        check(home.stats[1].value.TextTransparency <= 0.2 and home.stats[1].main.BackgroundTransparency <= 0.1, "session values and tiles remain visible in " .. id)
        check(w.HomePage.platformIcon.parts[1].BackgroundColor3 == w.theme.ContentColor, "platform logo follows " .. id)
    end
    w:ChangeTheme(previous)
end
local themes = w:OpenThemes()
check(#themes.cards == 60, "the complete theme picker renders all sixty previews")
check(themes.visibleCount == 60 and #themes.filters == 8 and themes.root.Parent == w.elements, "theme search and family filters belong to the content panel")
do
local originalThemeElements, originalThemeView = w.elements.AbsoluteSize, themes.root.AbsoluteWindowSize
local originalThemeListView = themes.list.AbsoluteWindowSize
local themeGrid = childOfClass(themes.list, "UIGridLayout")
local originalThemeGridSize = themeGrid.AbsoluteContentSize
for _, dimensions in ipairs({ { 280, 240 }, { 520, 400 }, { 820, 720 } }) do
    local width, height = dimensions[1], dimensions[2]
    w.elements.AbsoluteSize = Vector2.new(width, height)
    themes.root.AbsoluteWindowSize = Vector2.new(width - 20, height)
    themes:Layout()
    local mainHeight, contentHeight = themes.main.Size.Y.Offset, themes.content.Size.Y.Offset
    check(mainHeight <= height - 44 and not themes.root.ScrollingEnabled, "the complete theme page fits its viewport and does not scroll its header away")
    inside(themes.search, width - 40, contentHeight, "theme search")
    if themes.families.Visible then inside(themes.families, width - 40, contentHeight, "theme families") end
    inside(themes.list, width - 40, contentHeight, "theme results")
    local view = themes.list.Size.Y.Offset
    themes.list.AbsoluteWindowSize = Vector2.new(width - 40, view)
    themeGrid.AbsoluteContentSize = Vector2.new(width - 40, 60 * 168 - 12)
    themes._scrollers[1]:Queue()
    local searchAt, familiesAt = themes.search.Position, themes.families.Position
    themes.list.CanvasPosition = Vector2.new(0, themes.list.CanvasSize.Y.Offset - view)
    themes.list:GetPropertyChangedSignal("CanvasPosition"):Fire()
    check(themes._scrollers[1].atEnd and themes.search.Position == searchAt and themes.families.Position == familiesAt, "all sixty previews remain reachable without moving search and filters")
end
w.elements.AbsoluteSize, themes.root.AbsoluteWindowSize = originalThemeElements, originalThemeView
themes.list.AbsoluteWindowSize, themeGrid.AbsoluteContentSize = originalThemeListView, originalThemeGridSize
themes:Layout()
end
local function searchThemes(query)
    themes.search.Text = query
    themes.search:GetPropertyChangedSignal("Text"):Fire()
end
searchThemes("conexao")
check(themes.visibleCount == 1 and themes.cards[1].frame.Visible, "theme search matches accents and names")
searchThemes("ÔNIX")
check(themes.visibleCount == 1 and themes.cards[6].frame.Visible, "theme search accepts upper-case accented characters")
searchThemes("magenta")
check(themes.visibleCount == 1 and themes.cards[7].frame.Visible, "search matches palette descriptions")
themes.filters[6].button.MouseButton1Click:Fire()
check(themes.group == "Claros" and themes.visibleCount == 0 and themes.empty.Visible, "family filters combine with the current query and show an empty state")
searchThemes("")
check(themes.visibleCount == 10 and not themes.empty.Visible, "the light family contains ten authored themes")
themes._scrollers[1].desiredY, themes._scrollers[1].atEnd = 800, true
themes:SetGroup("Todos")
check(themes.visibleCount == 60 and themes._scrollers[1].desiredY == 0 and not themes._scrollers[1].atEnd, "filter changes reset the gallery scroll instead of staying at an old bottom")
local originalPickerSize = w.elements.AbsoluteSize
for _, viewportWidth in ipairs({ 280, 520, 820 }) do
    w.elements.AbsoluteSize = Vector2.new(viewportWidth, 600)
    themes:Layout()
    local expectedColumns = viewportWidth < 460 and 1 or (viewportWidth >= 740 and 3 or 2)
    local grid = childOfClass(themes.list, "UIGridLayout")
    check(math.abs(grid.CellSize.X.Scale - 1 / expectedColumns) < 0.001, "gallery adapts to available phone, tablet and desktop content widths")
end
w.elements.AbsoluteSize = originalPickerSize
themes:Layout()
local function luminance(color)
    local function linear(c) return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055)^2.4 end
    return 0.2126 * linear(color.R) + 0.7152 * linear(color.G) + 0.0722 * linear(color.B)
end
local function contrast(a, b)
    local first, second = luminance(a), luminance(b)
    return (math.max(first, second) + 0.05) / (math.min(first, second) + 0.05)
end
local ids, names, signatures = {}, {}, {}
local beforeThemeInstances = #w.instances
for index, entry in ipairs(UI.Themes) do
    local theme = entry.theme
    local signature = theme.AccentColor:ToHex()
    for _, key in ipairs({ "WindowColor", "SliderProgress" }) do
        for _, point in ipairs(theme[key].Keypoints) do signature ..= "/" .. point.Value:ToHex() end
    end
    check(not ids[entry.id] and not names[entry.name] and not signatures[signature], "theme ids, names and complete palettes must be unique: " .. entry.id)
    ids[entry.id], names[entry.name], signatures[signature] = true, true, true
    for _, key in ipairs({ "WindowColor", "ElementGradient", "TabBackground" }) do
        for _, point in ipairs(theme[key].Keypoints) do
            assert(contrast(theme.ContentColor, point.Value) >= 4.5, "unreadable text in " .. entry.id .. " / " .. key)
        end
    end
    check(contrast(theme.ContentColor, theme.StatBackground) >= 4.5, "theme text has sufficient contrast on preview and card surfaces: " .. entry.id)
    themes.cards[index].hit.MouseButton1Click:Fire()
    check(w.ThemeId == entry.id and themes.cards[index].selected.Visible and w.theme.ContentColor == theme.ContentColor, "every preview applies the corresponding complete theme: " .. entry.id)
    check(themes.cards[index].title.TextColor3 == theme.ContentColor and childOfClass(themes.cards[index].preview, "UIGradient").Color == theme.WindowColor, "preview keeps its own text and window colors after theme switches: " .. entry.id)
end
check(#w.instances == beforeThemeInstances, "cycling through all sixty themes reuses existing preview instances")
themes.cards[2].hit.MouseButton1Click:Fire()
check(w.ThemeId == "aurora" and themes.cards[2].selected.Visible and w.theme.AccentColor == UI.Themes[2].theme.AccentColor, "theme preview colors match the applied palette")
w:OpenSettings()
check(w.selectedTab == w.SettingsTab and themes.closed, "opening settings closes the overlay")
local beforeThemeConnections, beforeReopenInstances = #w.connections, #w.instances
for i = 1, 3 do w:OpenThemes():Close() end
check(#w.connections == beforeThemeConnections and #w.instances == beforeReopenInstances, "reopening the sixty-theme gallery releases its previews and filter handlers")

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
w:OpenHome()
w:Hide()
check(not w._conexaoPanel and w.selectedTab == w.HomeTab, "hiding preserves the profile as a normal internal page")
w:Show()
check(w.selectedTab == w.HomeTab and w.HomePage.content.Parent == w.elements, "reopening keeps the profile inside the main panel")
w:CloseProfile()

local previousIdentify = _G.identifyexecutor
_G.identifyexecutor = function() return "Test Executor", "1.2.3" end
check(not pcall(UI.CreateWindow, UI, { Id = "DeniedStudioExecutor" }), "Studio cannot mask an explicitly unlisted executor report")
_G.identifyexecutor = nil
local ew = UI:CreateWindow({ Id = "ExecutorTest", name = "ExecutorTest", sidebarLayout = false })
check(not ew.ProfileButton and ew.ExecutorInfo.name == "Roblox Studio" and ew.ExecutorInfo.support == "studio", "Studio remains available for development with the top-tab layout")
ew:OpenHome()
check(ew.selectedTab == ew.HomeTab and ew.HomePage.content.Parent == ew.elements and not ew._conexaoPanel, "the top-tab layout also presents the profile inside its content panel")
ew:Unload()
check(not ew.HomePage and not ew.HomeTab and #ew.connections == 0, "unloading with a profile open releases its page references and handlers")
_G.identifyexecutor = previousIdentify

local previousAsset, previousStudio = _G.getcustomasset, game:GetService("RunService").IsStudio
_G.identifyexecutor = function() return "Delta", "1.174.31136" end
_G.getcustomasset = nil
game:GetService("RunService").IsStudio = function() return false end
local deltaWindow = UI:CreateWindow({ Id = "DeltaFallback341" })
local deltaPage = deltaWindow:OpenHome()
check(deltaPage.executorIcon.kind == "delta" and not deltaPage.executorIcon.artwork and #deltaPage.executorIcon.parts == 3, "Delta has a local geometric fallback when custom assets are unavailable")
check(deltaPage.platformIcon.kind == "roblox" and deltaPage.platformBadge.Text == "Roblox", "a Roblox client shows the Roblox mark and platform name")
deltaWindow:Unload()
local localAssetCalls, localAssetPath = 0, nil
_G.getcustomasset = function(path)
    localAssetCalls += 1
    localAssetPath = path
    local decoded
    for _, candidate in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        if candidate.Name == "Filesystem" then
            local node = candidate
            for part in string.gmatch(path, "[^/]+") do node = node and node:FindFirstChild(part) end
            if node then decoded = node.Value end
        end
    end
    local id = path:match("/([a-z0-9]+)%-logo")
    local catalog = serde.decode("json", fs.readFile(root .. "/../../assets/executors/catalog.json"))
    local expected
    for _, entry in ipairs(catalog) do if entry.id == id and entry.file then expected = fs.readFile(root .. "/../../assets/executors/" .. entry.file) end end
    check(expected and decoded == expected, "embedded logo decodes to its exact packaged PNG: " .. tostring(id))
    return "rbxasset://local/" .. id .. "-logo.png"
end
deltaWindow = UI:CreateWindow({ Id = "DeltaArtwork341" })
deltaPage = deltaWindow:OpenHome()
check(deltaPage.executorIcon.artwork and deltaPage.fields[1].icon.artwork and deltaPage.executorIcon.parts[1].Image == "rbxasset://local/delta-logo.png", "Delta badge and executor card render the embedded logo through the local asset API")
check(localAssetCalls == 1 and localAssetPath:find("delta-logo-256-v1.png", 1, true), "the bundled logo is cached locally once instead of downloaded for each badge")
deltaWindow:Hide()
check(deltaPage.executorIcon.parts[1].ImageTransparency == 1 and deltaPage.platformIcon.parts[1].BackgroundTransparency == 1, "image and vector logos fade with the profile")
deltaWindow:Show()
check(deltaPage.executorIcon.parts[1].ImageTransparency == 0 and deltaPage.platformIcon.parts[1].BackgroundTransparency == 0, "reopening restores both logo types")
deltaWindow:Unload()
local catalog = serde.decode("json", fs.readFile(root .. "/../../assets/executors/catalog.json"))
for _, entry in ipairs(catalog) do
    _G.identifyexecutor = function() return entry.name, "1.0" end
    local client = UI:CreateWindow({ Id = "Brand35_" .. entry.id })
    local page = client:OpenHome()
    check(page.executorIcon.kind == entry.id and page.fields[1].icon.kind == entry.id and client.ExecutorInfo.version == "1.0", "permitted runtime names keep their logo and separate version: " .. entry.name)
    check((page.executorIcon.artwork == true) == (entry.file ~= nil), "known images and initials fallbacks match the catalogue: " .. entry.name)
    client:Unload()
end
UI:RegisterExecutorIcon("Wave", 987654321, { "Cliente Pessoal" })
_G.identifyexecutor = function() return "Cliente Pessoal", "2" end
check(not pcall(UI.CreateWindow, UI, { Id = "UnapprovedIconAlias" }), "a registered logo alias does not grant executor access")
_G.identifyexecutor = function() return "Wave", "2" end
local branded = UI:CreateWindow({ Id = "CustomBrand35" })
check(branded:OpenHome().executorIcon.parts[1].Image == "rbxassetid://987654321", "scripts can customize the image of a permitted client")
branded:Unload()
do
    local beforeInstances, beforeWindows = #w.instances, #w.screenGui:GetChildren()
    for _, name in ipairs({ "Novo Cliente", "Delta Clone", "Delta Runtime", "DeltaX", "Codex", "Velocity", "Dеlta" }) do
        _G.identifyexecutor = function() return name, "1" end
        local accepted, message = pcall(UI.CreateWindow, UI, { Id = "BundleTest", name = "Blocked" })
        check(not accepted and tostring(message):find("executor não suportado", 1, true), "unlisted or misleading names cannot create a window: " .. name)
        check(not w.unloaded and #w.instances == beforeInstances and #w.screenGui:GetChildren() == beforeWindows, "rejected execution preserves existing windows and creates no UI")
    end
    UI.SupportedExecutors[5] = "Codex"
    _G.identifyexecutor = function() return "Codex" end
    check(not pcall(UI.CreateWindow, UI, { Id = "MutatedPublicList" }), "editing the public list cannot change the compiled support policy")
    UI.SupportedExecutors[5] = nil
    _G.identifyexecutor = nil
    check(not pcall(UI.CreateWindow, UI, { Id = "UnidentifiedClient" }), "an unidentified client cannot create a window")
end
_G.getcustomasset, _G.identifyexecutor = previousAsset, previousIdentify
game:GetService("RunService").IsStudio = previousStudio

do
local playersService, statsService, runService = game:GetService("Players"), game:GetService("Stats"), game:GetService("RunService")
local previousPlayers, previousMaximum, previousNetwork = playersService.GetPlayers, playersService.MaxPlayers, statsService.Network
playersService.GetPlayers = function() return { {}, {}, {} } end
playersService.MaxPlayers = 12
statsService.Network = { ServerStatsItem = { ["Data Ping"] = { GetValue = function() return 87 end } } }
local statsWindow = UI:CreateWindow({ Id = "LiveSession35" })
local statsPage = statsWindow:OpenHome()
for i = 1, 120 do runService.RenderStepped:Fire(1 / 60) runService.Heartbeat:Fire(1 / 60) end
statsPage:RefreshStats()
local stats = statsWindow:GetSessionStats()
check(stats.players == 3 and stats.maximum == 12 and stats.fps == 60 and stats.ping == 87, "dashboard samples real player, FPS and latency providers")
check(statsPage.dashboard.stats[1].value.Text == "3" and statsPage.dashboard.stats[2].value.Text == "12" and statsPage.dashboard.stats[3].value.Text == "87 ms", "live samples update the server metrics in the reference grid")
check(stats.elapsed > 1.99 and stats.elapsed < 2.01, "session duration accumulates elapsed time rather than counting update loops")
statsWindow.configuration.autoSave = false
statsPage:RefreshStats()
check(statsPage.dashboard.stats[6].value.Text == "Desativado" and statsPage.dashboard.accountSave.Text:find("Desativado", 1, true), "session and account cards share the live save state")
statsWindow:Unload()
local elapsedBefore = statsWindow:GetSessionStats().elapsed
runService.Heartbeat:Fire(1)
check(statsWindow:GetSessionStats().elapsed == elapsedBefore and #statsWindow.connections == 0, "unloading disconnects session sampling")
playersService.GetPlayers, playersService.MaxPlayers, statsService.Network = previousPlayers, previousMaximum, previousNetwork
local unavailable = UI:CreateWindow({ Id = "UnknownMetrics35" })
check(unavailable:GetSessionStats().fpsText == "—" and unavailable:GetSessionStats().pingText == "—", "unavailable metrics stay unknown instead of showing fabricated values")
unavailable:Unload()
end

local themeWindow = UI:CreateWindow({ Id = "ThemePersist34", name = "ThemePersist34" })
themeWindow:ChangeTheme("porcelana")
themeWindow.TransparencySlider:Set(23)
themeWindow:Unload()
themeWindow = UI:CreateWindow({ Id = "ThemePersist34", name = "ThemePersist34" })
check(themeWindow.ThemeId == "porcelana" and luminance(themeWindow.theme.ContentColor) < 0.1 and themeWindow.TransparencySlider.value == 23, "a newly added light theme and its transparency survive reexecution")
themeWindow:Unload()
local localeWindow = UI:CreateWindow({ Id = "LocaleOverride34", translations = { ["pt-br"] = { Haptics = "Vibração personalizada" } } })
for _, element in ipairs(localeWindow.SettingsTab.elements) do
    if element.name == "Haptics" then check(element.title.Text == "Vibração personalizada", "developer translations override the built-in Portuguese pack") end
end
localeWindow:Unload()
localeWindow = UI:CreateWindow({ Id = "English34", locale = "en" })
for _, element in ipairs(localeWindow.SettingsTab.elements) do
    if element.name == "Haptics" then check(element.title.Text == "Haptics", "explicit native English locale remains supported") end
end
localeWindow:Unload()

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
check(demoWindow and #demoWindow.tabs == 2 and demoWindow.selectedTab == demoWindow.HomeTab and demoWindow.SettingsTab.topbarItem, "the standalone demo opens the built-in dashboard with settings still visible")
DemoUI:Destroy()
check(demoWindow.unloaded, "standalone demo tears down cleanly")

local ComponentsUI, componentsWindow = (function()
-- COMPONENTS
return UI, window
end)()
check(componentsWindow and #componentsWindow.tabs >= 7 and componentsWindow.selectedTab.name == "Testes", "the interactive component example opens its test controls")
check(#componentsWindow.tags == 0 and not componentsWindow.BrandHeader.tagSlot.Visible, "the example starts without a TESTES badge in the header")
local function exerciseComponents(window)
    local function find(name, list)
        for _, element in ipairs(list or {}) do
            if element.name == name then return element end
            if element.elements then local found = find(name, element.elements) if found then return found end end
        end
    end
    local function control(name)
        for _, tab in ipairs(window.tabs) do local found = find(name, tab.elements) if found then return found end end
        error("Missing example control: " .. name)
    end
    local function click(name)
        local item = control(name)
        local tab = item.tab
        while tab and tab.__type == "Group" do tab = tab.tab end
        if tab and tab.Select then tab:Select() end
        item.interact.MouseButton1Click:Fire()
        return item
    end
    local function last() return window.Feedback.messages[#window.Feedback.messages] end
    local counter, log = control("Interações nesta execução"), control("Eventos dos callbacks")
    local lastAction, paragraph = control("Última ação"), control("Texto dinâmico")
    local kinds = {}
    local function collect(elements)
        for _, element in ipairs(elements) do
            kinds[element.__type] = true
            if element.elements then collect(element.elements) end
        end
    end
    for _, tab in ipairs(window.tabs) do collect(tab.elements) end
    for _, kind in ipairs({ "Button", "Toggle", "Slider", "Dropdown", "Input", "Keybind", "ColorPicker", "Text", "Progress", "Console", "Statistic", "Divider", "Section", "Group" }) do
        check(kinds[kind], "the example includes the public component: " .. kind)
    end
    check(control("Testar botão").tab.elements[3] == control("Testar botão"), "the main button stays ahead of tall readouts in the first tab")
    check(counter.value == 0, "restoring demo values does not manufacture interactions")
    click("Testar botão")
    check(counter.value == 1 and last().title == "Botão clicado" and last().flavor == "success", "the example button actually notifies and counts its callback")
    local toggle = control("Toggle com notificação")
    toggle.interact.MouseButton1Click:Fire()
    check(toggle.value and last().content == "Você ativou o toggle.", "turning the example toggle on produces the matching notification")
    toggle.interact.MouseButton1Click:Fire()
    check(not toggle.value and last().content == "Você desativou o toggle.", "turning the toggle off produces different feedback")
    click("Notificação só com título")
    check(last().title == "Ação concluída" and last().content == "" and not last().descriptionLabel, "the interactive example demonstrates a title-only notification")
    click("Bloquear o botão de teste")
    local blocked = counter.value
    click("Testar botão")
    check(control("Testar botão").locked and counter.value == blocked, "the lock example prevents the protected button callback")
    click("Bloquear o botão de teste");click("Testar botão")
    check(not control("Testar botão").locked and last().title == "Botão clicado", "unlock makes the example button usable again")
    local slider = control("Porcentagem editável")
    slider.tab:Select()
    local before = counter.value
    slider.callback(25, true)
    check(counter.value == before and control("Progresso da porcentagem"):Get() == 25, "drag feedback updates the example progress without notification spam")
    slider._valueInput.button.MouseButton1Click:Fire()
    slider.valueInput.Text = "73,5%"
    slider.valueInput:ReleaseFocus()
    check(slider.value == 73.5 and last().title == "Porcentagem confirmada" and control("Valor escolhido no slider").value == 73.5, "typing in the example slider updates its notification and linked statistic")
    control("Número com precisão"):Set(-3.25)
    check(last().content == "Valor: -3.25", "the precise-number callback reports its committed value")
    control("Número inteiro"):Set(7)
    check(last().content == "7", "integer sliders have a working callback")
    local single = control("Escolha única")
    single:Open();single.selectionPanel.items[2].hit.MouseButton1Click:Fire()
    check(single:GetValue() == "Opção 2" and last().content == "Opção 2", "single-choice panel actions call the example's callback")
    local multi = control("Escolha múltipla")
    multi:Open();multi.selectionPanel.actions[3].MouseButton1Click:Fire()
    check(#multi.value == 5 and last().content:find("Opção 5", 1, true), "Select all reports all five example options")
    multi.selectionPanel.actions[2].MouseButton1Click:Fire()
    check(#multi.value == 0 and last().content == "Nenhuma opção selecionada", "clearing a multiple dropdown reports its empty selection")
    multi:Close()
    click("Selecionar as cinco por código");check(#multi.value == 5, "the programmatic selection example works")
    click("Limpar seleção por código");check(#multi.value == 0, "the programmatic clear example works")
    click("Atualizar opções do dropdown");check(#multi.options == 6 and last().title == "Lista atualizada", "the example can refresh dropdown options at runtime")
    local input = control("Texto de exemplo")
    input.input.Text = "Teste de callback";input.input.FocusLost:Fire()
    check(input.value == "Teste de callback" and last().content == "Teste de callback", "committing the example textbox sends its actual text")
    local numeric = control("Campo numérico")
    numeric.input.Text = "25";numeric.input.FocusLost:Fire()
    check(numeric.value == "25" and last().content == "25", "numeric input also has visible callback feedback")
    local color = control("Seletor de cor")
    color:Set(Color3.fromRGB(10, 20, 30));color:SetAlpha(0.5)
    click("Notificar a cor escolhida")
    check(last().content:find("#0A141E", 1, true) and last().content:find("50%", 1, true), "the color example reports real RGB and alpha values")
    click("Executar ação do atalho")
    check(last().title == "Atalho acionado", "mobile users can run the same action as the keyboard shortcut")
    local bind = control("Atalho de exemplo")
    bind:Set(Enum.KeyCode.F8)
    check(last().title == "Atalho alterado" and last().content == "F8", "rebinding the demo shortcut produces feedback")
    local inputService = game:GetService("UserInputService")
    inputService.InputBegan:Fire({ UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.F8 }, false)
    check(last().title == "Atalho acionado", "a real keyboard event invokes the demo shortcut")
    inputService.InputBegan:Fire({ UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.F7 }, false)
    check(last().content == "A tecla está pressionada.", "the hold example reports the press edge")
    inputService.InputEnded:Fire({ UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.F7 })
    check(last().content == "A tecla foi solta.", "the hold example reports the release edge")
    for _, item in ipairs({ { "Notificação padrão", "info" }, { "Aviso de sucesso", "success" }, { "Aviso de atenção", "warning" }, { "Aviso de erro", "error" } }) do
        click(item[1]);check(last().flavor == item[2], "every notification-style example is wired to its intended type")
    end
    local message = last();click("Fechar o último aviso")
    check(message._dismissed, "the close-last example actually dismisses its notification")
    click("Toast no topo");check(last().main.Parent == window._toastsTop, "the top-toast example uses the top stack")
    click("Toast embaixo");check(last().main.Parent == window._toastsBottom, "the bottom-toast example uses the bottom stack")
    local textService = game:GetService("TextService")
    local measure = textService.GetTextBoundsAsync
    textService.GetTextBoundsAsync = function(_, params)
        local length, size = utf8.len(tostring(params.Text)) or #tostring(params.Text), params.Size
        local extent = length * size * 0.55
        return Vector2.new(math.min(extent, params.Width), math.max(size, math.ceil(extent / math.max(1, params.Width)) * size * 1.2))
    end
    click("Notificação com texto longo")
    textService.GetTextBoundsAsync = measure
    check(last().scrollable and utf8.len(lastAction.text) <= 161, "the long-copy example scrolls internally while its action summary remains compact")
    click("Popup com confirmação")
    local confirmation
    for _, node in ipairs(window.instances) do
        if node:IsA("TextLabel") and node.Text == "Confirmar" then
            for _, child in ipairs(node.Parent:GetChildren()) do if child:IsA("TextButton") then confirmation = child break end end
        end
    end
    check(confirmation ~= nil, "the popup example exposes its confirmation action")
    confirmation.MouseButton1Click:Fire()
    check(last().title == "Popup" and last().content == "Você escolheu confirmar.", "popup choices execute their own example callbacks")
    click("Avançar progresso em etapas")
    check(control("Progresso em etapas"):Get() == 20 and paragraph.name == "Texto atualizado" and paragraph.text:find("20%", 1, true), "button callbacks update both a progress widget and a paragraph")
    click("Escrever no console");check(log:Get():find("Uma nova linha", 1, true), "the console example appends actual callback output")
    click("Limpar console");check(log:Get() == "", "the clear-console example removes its output")
    click("Botão esquerdo");check(last().title == "Grupo esquerdo", "nested left-column buttons have working callbacks")
    click("Toggle direito");check(last().title == "Grupo direito", "nested right-column toggles have working callbacks")
    click("Atualizar selo do topo");check(window.tags[1].text:find("AÇÕES", 1, true), "the header-tag example updates its displayed text")
    local autosave = window.configuration.autoSave
    window.configuration.autoSave = false
    click("Salvar escolhas agora")
    local saved = slider.value
    slider:Set(15)
    local interactions = counter.value
    click("Carregar escolhas salvas")
    check(slider.value == saved and counter.value == interactions + 1 and last().title == "Restauração", "manual restore reapplies demo values without flooding callbacks with notifications")
    window.configuration.autoSave = autosave
    click("Zerar contador de interações");check(counter.value == 0, "the reset-counter example resets its readout")
end
exerciseComponents(componentsWindow)
ComponentsUI:Destroy()
check(componentsWindow.unloaded and #componentsWindow.connections == 0, "the interactive example releases its handlers when unloaded")

print("PASS: " .. checks .. " public-bundle / integration assertions (Roblox services simulated)")
