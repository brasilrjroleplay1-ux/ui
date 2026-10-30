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
local function apart(first, second, width, height, message)
    local a, b = rect(first, width, height), rect(second, width, height)
    check(a.x + a.w <= b.x or b.x + b.w <= a.x or a.y + a.h <= b.y or b.y + b.h <= a.y, message)
end
for _, width in ipairs({ 180, 240, 280, 299, 300, 320, 399, 400, 465, 700 }) do
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
    apart(view.account, view.client, cards.w, cards.h, "account and client cards never overlap")
    local identityHeight = view.identity.Size.Y.Offset
    local cover = inside(view.cover, width, identityHeight)
    inside(view.status, cover.w, cover.h)
    inside(view.avatarPlate, width, identityHeight)
    inside(profile.playerName, width, identityHeight)
    inside(profile.username, width, identityHeight)
    apart(view.avatarPlate, profile.playerName, width, identityHeight, "the name never overlaps the avatar after resizing")
    apart(profile.playerName, profile.username, width, identityHeight, "the display name leaves room for the username")
    apart(profile.username, view.badges, width, identityHeight, "identity badges remain below the username")
    local badges = inside(view.badges, width, identityHeight)
    inside(view.executorBadge, badges.w, badges.h)
    inside(view.platformBadge, badges.w, badges.h)
    apart(view.executorBadge, view.platformBadge, badges.w, badges.h, "executor and platform logos keep separate hit areas")
    local account = inside(view.account, cards.w, cards.h)
    local client = inside(view.client, cards.w, cards.h)
    inside(profile.userId, account.w, account.h)
    inside(profile.accountName, account.w, account.h)
    inside(profile.copyButton, account.w, account.h)
    apart(profile.userId, profile.copyButton, account.w, account.h, "copying the ID never covers the number")
    inside(profile.executorVersion, client.w, client.h)
    inside(profile.environment, client.w, client.h)
    inside(view.footer, width, height)
    inside(view.storage, width, height)
    apart(view.footer, view.storage, width, height, "version and storage stay readable in both footer layouts")
    check(view.cards.Position.Y.Offset >= 44 + identityHeight + 12 and view.main.Size.Y.Scale == 0 and profile.tab._scrollController.frame == profile.content, "the stacked profile remains owned by the existing scroll controller")
    profile.tab.tabPageLayout.AbsoluteContentSize = Vector2.new(width, height)
    profile.content.AbsoluteWindowSize = Vector2.new(width, 200)
    profile.tab._scrollController.desiredY = 10000
    profile.tab._scrollController:Sync()
    check(profile.content.CanvasSize.Y.Offset >= height and profile.content.CanvasPosition.Y + 200 >= height, "the profile can scroll to its footer after a width change")
end
local beforeNotice = view.main.Size.Y.Offset
profile.copyButton.MouseButton1Click:Fire()
check(view.notice.Visible and view.main.Size.Y.Offset > beforeNotice, "copy feedback expands the native scroll extent")
inside(view.notice, 700, view.main.Size.Y.Offset)
w:OpenProfile()
check(not view.notice.Visible and view.main.Size.Y.Offset == beforeNotice, "reopening the account clears transient feedback without adding pages")
w:OpenHome()
w.HomeTab.topbarItemInteract.MouseButton1Click:Fire()
check(w.selectedTab == home.tab and w.selectedTab ~= profile.tab, "the Home item consistently opens Home")
w:OpenProfile()
w:ChangeTheme("porcelana")
check(profile.playerName.TextColor3 == w.theme.ContentColor and profile.platformIcon.parts[1].BackgroundColor3 == w.theme.ContentColor, "account text and platform artwork follow theme changes")
local lightCover = view.coverGradient.Color
w:ChangeTheme("conexao")
check(view.coverGradient.Color ~= lightCover and profile.playerName.FontFace.Weight == Enum.FontWeight.Bold and view.avatarRim.Color == w.theme.AccentStroke, "cover, identity frame and bold typography follow dark and light palettes")
view:_setShown(false, false)
check(profile.avatar.ImageTransparency == 1 and view.avatarPlate.BackgroundTransparency == 1 and view.avatarRim.Transparency == 1, "hiding fades the avatar frame and account artwork together")
view:_setShown(true, false)
check(profile.avatar.ImageTransparency == 0 and view.avatarRim.Transparency < 1 and view.cover.BackgroundTransparency < 1, "restoring reveals the complete account composition")
w.ProfileTab:Remove()
check(not w.ProfilePage and not w.ProfileTab and w.HomePage == home, "removing profile preserves Home")
local rebuilt = w:OpenProfile()
check(rebuilt ~= profile and w.selectedTab == rebuilt.tab, "the avatar can rebuild a removed profile page")
w:Unload()
check(not w.ProfilePage and not w.HomePage and #w.connections == 0, "unload releases both pages and all navigation handlers")
print("PASS: " .. checks .. " labelled sidebar and distinct account navigation checks")
