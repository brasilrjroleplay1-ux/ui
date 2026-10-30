-- Regressions reported in 3.6: sidebar names, search position and profile/Home aliasing.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local w = UI:CreateWindow({ Id = "Navigation361", configuration = { autoSave = false, autoLoad = false } })
check(w.searchAction.action.Parent == w.actionContainer and table.find(w.BrandHeader.actions, w.searchAction.action), "search is present in the top action group")
check(w.SettingsTab.topbarItemTitle.Visible and w.profileLabels.Visible, "the standard window shows tab titles and player details")
check(w.profileName.Text == game:GetService("Players").LocalPlayer.DisplayName and w.profileSubtitle.Text == w.ExecutorInfo.name, "the sidebar footer contains the real player name and executor")
local home = w:OpenHome()
w.ProfileButton.MouseButton1Click:Fire()
local profile = w.ProfilePage
check(profile and profile ~= home and profile.tab ~= home.tab and w.selectedTab == profile.tab, "the avatar opens a distinct account page")
check(profile.playerName.Text == game:GetService("Players").LocalPlayer.DisplayName and profile.userId.Text == tostring(game:GetService("Players").LocalPlayer.UserId), "the account page shows player identity")
check(profile.executorName.Text == w.ExecutorInfo.name and profile.environment.Text == w.ExecutorInfo.environment and profile.avatar.Image:find("w=420&h=420", 1, true), "profile includes executor, environment and a full-resolution avatar")
check(profile.content.Parent == w.elements and not w._conexaoPanel and not w.screenGui:FindFirstChild("ConexaoOverlay"), "profile stays in the native panel without a popup")
profile.backButton.MouseButton1Click:Fire()
check(w.selectedTab == home.tab, "Back restores Home when profile was opened from Home")
local tab = w:CreateTab({ name = "Nome da minha aba", icon = 93364949241311 })
check(tab.topbarItemTitle.Visible and tab.topbarItemTitle.Text == "Nome da minha aba" and tab.topbarItemTitle.AutomaticSize == Enum.AutomaticSize.None, "user-created tab names remain visible and bounded")
local calls = 0
local toggle = tab:CreateToggle({ name = "Estado de teste", value = false, callback = function() calls += 1 end })
toggle:Set(true)
local previousCalls = calls
w.ProfileButton.MouseButton1Click:Fire()
profile.backButton.MouseButton1Click:Fire()
check(w.selectedTab == tab and toggle.value and calls == previousCalls, "profile navigation restores the original tab without replaying callbacks")
local connections, instances, tabs = #w.connections, #w.instances, #w.tabs
for _ = 1, 6 do w:OpenHome() w:OpenProfile() w:CloseProfile() end
check(w.ProfilePage == profile and w.HomePage == home and #w.connections == connections and #w.instances == instances and #w.tabs == tabs, "Home and profile reuse separate pages without accumulating handlers")
local function rect(node, width, height)
    local s, p, a = node.Size, node.Position, node.AnchorPoint
    local x, y = s.X.Scale * width + s.X.Offset, s.Y.Scale * height + s.Y.Offset
    return { x = p.X.Scale * width + p.X.Offset - a.X * x, y = p.Y.Scale * height + p.Y.Offset - a.Y * y, w = x, h = y }
end
local function inside(node, width, height)
    local r = rect(node, width, height)
    check(r.x >= 0 and r.y >= 0 and r.w > 0 and r.h > 0 and r.x + r.w <= width + 0.01 and r.y + r.h <= height + 0.01, "account content remains inside its parent")
    return r
end
local view = profile.view
for _, width in ipairs({ 180, 240, 320, 399, 400, 465, 700 }) do
    view.main.AbsoluteSize = Vector2.new(width, 600)
    view:Layout()
    local height = view.main.Size.Y.Offset
    inside(view.identity, width, height)
    inside(view.title, width, height)
    inside(profile.backButton, width, height)
    local title, back = rect(view.title, width, height), rect(profile.backButton, width, height)
    check(title.x + title.w <= back.x, "profile heading leaves room for Back")
    local cards = inside(view.cards, width, height)
    for _, card in ipairs({ view.account, view.client }) do inside(card, cards.w, cards.h) end
    inside(profile.playerName, width, 96)
    inside(profile.username, width, 96)
    inside(profile.userId, view.account.Size.X.Offset, 164)
    inside(profile.executorVersion, view.client.Size.X.Offset, 164)
end
w:OpenHome()
w.HomeTab.topbarItemInteract.MouseButton1Click:Fire()
check(w.selectedTab == home.tab and w.selectedTab ~= profile.tab, "the Home item consistently opens Home")
w:OpenProfile()
w:ChangeTheme("porcelana")
check(profile.playerName.TextColor3 == w.theme.ContentColor and profile.platformIcon.parts[1].BackgroundColor3 == w.theme.ContentColor, "account text and platform artwork follow theme changes")
w.ProfileTab:Remove()
check(not w.ProfilePage and not w.ProfileTab and w.HomePage == home, "removing profile preserves Home")
local rebuilt = w:OpenProfile()
check(rebuilt ~= profile and w.selectedTab == rebuilt.tab, "the avatar can rebuild a removed profile page")
w:Unload()
check(not w.ProfilePage and not w.HomePage and #w.connections == 0, "unload releases both pages and all navigation handlers")
print("PASS: " .. checks .. " labelled sidebar and distinct account navigation checks")
