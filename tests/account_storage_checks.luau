-- Execute real persistence for multiple Roblox accounts against the public bundle.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local players = game:GetService("Players")
local player = players.LocalPlayer
local previous = { player.UserId, player.Name, player.DisplayName }
local function account(id, name) player.UserId, player.Name, player.DisplayName = id, name, name end
local function make()
    local w = UI:CreateWindow({ Id = "ScopedHub", name = "Scoped Hub", theme = "conexao", configuration = { fileName = "choices", customFolder = "Project" } })
    local tab = w:CreateTab({ name = "Controles do script" })
    local toggle = tab:CreateToggle({ name = "Toggle", flag = "account_toggle", value = false })
    local slider = tab:CreateSlider({ name = "Slider", flag = "account_slider", range = { 0, 100 }, increment = 0.5, value = 5, format = "percent" })
    local drop = tab:CreateDropdown({ name = "Dropdown", flag = "account_drop", options = { "One", "Two", "Three" }, multiSelect = true, value = { "One" } })
    local input = tab:CreateInput({ name = "Input", flag = "account_input", value = "Default" })
    return w, { toggle, slider, drop, input }
end
local function defaults(c) return c[1].value == false and c[2].value == 5 and #c[3].value == 1 and c[3].value[1] == "One" and c[4].value == "Default" end
local function haptics(w)
    for _, control in ipairs(w.SettingsTab.elements) do if control.name == "Haptics" then return control end end
end
account(101, "ContaA")
local a, ca = make()
check(a.NotificationPosition == "top", "a new account starts with upper-right notifications")
a:SetNotificationPosition("Bottom")
check(not a.ConfigurationScope.shared and a.configuration.customFolder:find("Accounts/101/", 1, true), "the default configuration namespace contains the actual account ID")
ca[1]:Set(true); ca[2]:Set(73.5); ca[3]:Set({ "Two", "Three" }); ca[4]:Set("Only A")
a:ChangeTheme("sakura");a.TransparencySlider:Set(41);haptics(a):Set(false)
a:SetSidebarIconsOnly(true)
a.Performance.controls.showStats:Set(true)
check(a:Save() and a:Save("Preset A"), "account A saves default choices and its named preset")
local aFolder, aPreferences = a.configuration.customFolder, a._preferencesPath
account(202, "ContaB")
local b, cb = make()
check(b.NotificationPosition == "top", "a different account does not inherit A's bottom notification position")
check(defaults(cb), "a different account never restores A's toggle, slider, dropdown or input")
check(b.ThemeId == "conexao" and b.UIPreferences.transparency == nil and b.settings.haptics == true, "appearance and native window settings are also isolated")
check(not b.UIPreferences.sidebarIconsOnly and not b.SidebarIconsOnlyToggle.value and b.sidebar.Size.X.Offset == 196, "another account does not inherit A's icons-only navigation preference")
check(not b.Performance.controls.showStats.value, "a different account does not inherit performance choices")
check(b.configuration.customFolder ~= aFolder and b._preferencesPath ~= aPreferences and not table.find(b:ListConfigs(), "Preset A"), "paths and named preset listings are account-specific")
cb[2]:Set(22);cb[3]:Set({ "Three" });cb[4]:Set("Only B")
b:ChangeTheme("oceano");b.TransparencySlider:Set(12)
check(b:Save() and b:Save("Preset B"), "account B saves independently")
account(101, "ContaA")
a, ca = make()
check(ca[1].value and ca[2].value == 73.5 and #ca[3].value == 2 and ca[4].value == "Only A", "returning to account A restores its own saved choices")
check(a.ThemeId == "sakura" and a.TransparencySlider.value == 41 and a.settings.haptics == false, "account A also restores its appearance and native preferences")
check(a.UIPreferences.sidebarIconsOnly and a.SidebarIconsOnlyToggle.value and a.sidebar.Size.X.Offset == 64, "returning to account A restores its own sidebar choice")
check(a.NotificationPosition == "bottom" and a.NotificationPositionDropdown.value[1] == "Inferior", "returning to account A restores its own notification position")
check(a.Performance.controls.showStats.value, "performance choices are restored for their own account")
check(table.find(a:ListConfigs(), "Preset A") and not table.find(a:ListConfigs(), "Preset B"), "named configurations do not leak between accounts")
-- Legacy files have no account attribution; leave them intact rather than auto-adopting them.
local fsRoot = game:GetService("ReplicatedStorage"):FindFirstChild("Filesystem")
local function file(path, contents)
    local node = fsRoot
    local parts = string.split(path, "/")
    for i, part in ipairs(parts) do
        local nextNode = node:FindFirstChild(part)
        if not nextNode then nextNode = Instance.new(i == #parts and "StringValue" or "Folder") nextNode.Name, nextNode.Parent = part, node end
        node = nextNode
    end
    if contents ~= nil then node.Value = contents end
    return node
end
local old = file("ConexaoUI/Configurations/Project/choices.rfld", file("ConexaoUI/Configurations/" .. aFolder .. "/choices.rfld").Value)
local oldPrefs = file("ConexaoUI/Configurations/Project/choices.rfld.ui.json", file(a._preferencesPath).Value)
local legacySettings = file("ConexaoUI/Settings/conexao.rfld", game:GetService("HttpService"):JSONEncode({ haptics = false }))
local oldBytes, oldPreferenceBytes, oldSettingsBytes = old.Value, oldPrefs.Value, legacySettings.Value
account(303, "ContaC")
local c, cc = make()
check(defaults(cc) and c.ThemeId == "conexao" and c.settings.haptics, "unattributed legacy files are not imported into a new account")
check(old.Value == oldBytes and oldPrefs.Value == oldPreferenceBytes and legacySettings.Value == oldSettingsBytes, "legacy files remain untouched")
account(101, "ContaA")
a, ca = make()
check(a:SetSharedConfiguration(true) and a.ConfigurationScope.nextShared and not a.ConfigurationScope.shared, "sharing is an explicit preference for this account and the next execution")
check(a.configuration.customFolder == aFolder and a.ConfigScopeStatus.text:find("Próxima execução", 1, true), "pending mode changes leave active writes in their original namespace")
a, ca = make()
check(a.ConfigurationScope.shared and a.configuration.customFolder:sub(1, 7) == "Shared/" and defaults(ca), "first use of a new shared profile starts from script defaults")
ca[1]:Set(true);ca[2]:Set(42);ca[3]:Set({ "One", "Two", "Three" });ca[4]:Set("Shared choices")
a:ChangeTheme("esmeralda");check(a:Save(), "an opted-in account can save a shared configuration")
account(202, "ContaB")
b, cb = make()
check(not b.ConfigurationScope.shared and cb[2].value == 22 and cb[4].value == "Only B" and b.ThemeId == "oceano", "A enabling sharing does not opt B in or replace B's private choices")
check(b:SetSharedConfiguration(true), "account B can explicitly opt into the shared profile")
b, cb = make()
check(b.ConfigurationScope.shared and cb[2].value == 42 and cb[4].value == "Shared choices" and #cb[3].value == 3 and b.ThemeId == "esmeralda", "sharing works only after the second account also opts in")
check(b:SetSharedConfiguration(false), "account B can return to its individual profile")
b, cb = make()
check(not b.ConfigurationScope.shared and cb[2].value == 22 and cb[4].value == "Only B" and b.ThemeId == "oceano", "turning sharing off restores the preserved individual profile")
-- Sections expand independently in one page, preserving their controls and descriptors.
local nav = b.SettingsNavigation
local userCalls = 0
cb[1].callback = function() userCalls += 1 end
for key in pairs(nav.sections) do nav:SetExpanded(key, false, false) end
for _, key in ipairs({ "appearance", "themes", "saving", "controls" }) do
    b:OpenSettings(key)
    check(nav.active == key and nav.sections[key].expanded and b.selectedTab == b.SettingsTab, "OpenSettings expands the requested section on the same settings page")
    for control, category in pairs(nav.membership) do
        local visible = nav.sections[category].expanded and control.__type ~= "Section"
        check(control.main.Visible == visible, "expanded sections keep their controls visible together without duplicate headings")
        if control.descriptor then check(control.descriptor.main.Visible == visible, "descriptor visibility follows its expanded section") end
    end
end
check(nav.sections.appearance.expanded and nav.sections.themes.expanded and nav.sections.saving.expanded and nav.sections.controls.expanded, "multiple settings sections can remain open at once")
check(userCalls == 0, "folding settings never reapplies script callbacks")
nav:SetExpanded("themes", false, true)
b:OpenSettings("appearance");b.ThemeGallery:_setShown(true)
check(not b.ThemeGallery.main.Visible, "the native reveal path cannot expose a collapsed theme section")
b:OpenSettings("themes");b:ChangeTheme("porcelana");b:Hide();b:Show()
check(b.ThemeGallery.main.Visible and nav.sections.themes.expanded and nav.sections.appearance.expanded, "expanded sections survive theme changes and window reopening")
nav:SetExpanded("appearance", false, true);nav:SetExpanded("controls", false, true)
local expected = table.clone(b.UIPreferences.settingsSections)
file(b.ConfigurationScope.metadataPath, "invalid json")
file(b.ConfigurationScope.metadataPath .. ".tmp", game:GetService("HttpService"):JSONEncode({ version = 1, shareAcrossAccounts = true }))
b, cb = make()
check(not b.ConfigurationScope.shared and cb[4].value == "Only B", "corrupt scope metadata and an uncommitted opt-in cannot activate sharing")
for key, expanded in pairs(expected) do check(b.SettingsNavigation.sections[key].expanded == expanded, "section expansion choices restore from this account's preferences") end
account(303, "ContaC")
c, cc = make()
check(c.SettingsNavigation.sections.appearance.expanded and not c.SettingsNavigation.sections.themes.expanded, "another account keeps its own section defaults instead of inheriting expanded sections")
account(202, "ContaB")
b, cb = make()
local http = game:GetService("HttpService")
local encode = http.JSONEncode
http.JSONEncode = function() error("simulated storage failure") end
b.ShareAcrossAccountsToggle:Set(true)
check(not b.ConfigurationScope.nextShared and not b.ShareAcrossAccountsToggle.value, "a failed opt-in write restores the individual toggle state")
http.JSONEncode = encode
local identity = players.LocalPlayer
local count = #fsRoot:GetDescendants()
players.LocalPlayer = nil
check(not pcall(UI.CreateWindow, UI, { name = "No identity" }) and #fsRoot:GetDescendants() == count, "a missing account identity never falls back to a shared storage bucket")
players.LocalPlayer = identity
local oldStudio, oldIdentify = game:GetService("RunService").IsStudio, _G.identifyexecutor
game:GetService("RunService").IsStudio = function() return false end
_G.identifyexecutor = function() return "Delta" end
for _, invalid in ipairs({ 0, -1, "../101" }) do
    player.UserId = invalid
    check(not pcall(UI.CreateWindow, UI, { name = "Invalid identity" }), "invalid production account IDs cannot select another account's namespace")
end
game:GetService("RunService").IsStudio, _G.identifyexecutor = oldStudio, oldIdentify
player.UserId = 202
b:Unload()
UI:Destroy()
player.UserId, player.Name, player.DisplayName = table.unpack(previous)
print("PASS: " .. checks .. " account isolation, explicit sharing and organized settings checks")
